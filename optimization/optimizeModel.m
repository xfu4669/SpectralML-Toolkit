function out = optimizeModel(cache,c,cancel,progress)
space=c.searchSpace; minBands=min(cellfun(@(f)size(f.XTrain,2),cache));
minRows=min(cellfun(@(f)size(f.XTrain,1),cache));
for j=1:numel(space)
    % Kernel names are categorical choices, not numeric bounds. Their NaN
    % Lower/Upper placeholders must never enter fold-capacity comparisons.
    if strcmp(space(j).Type,'categorical')
        assert(~isempty(space(j).Values),'SpectralML:SearchSpace', ...
            'Select at least one option for %s.',space(j).Name);
        continue;
    end
    assert(isscalar(space(j).Lower) && isscalar(space(j).Upper) && ...
        isfinite(space(j).Lower) && isfinite(space(j).Upper) && space(j).Lower<=space(j).Upper, ...
        'SpectralML:SearchSpace','Invalid numeric range for %s. Check its minimum and maximum.',space(j).Name);
    limit=Inf;
    switch space(j).Name
        case {'Components','NumComponents'}
            ranks=cellfun(@(f)rank(f.XTrain-mean(f.XTrain,1)),cache);
            limit=min([minBands,minRows-1,ranks(:)']);
        case 'NumPredictorsToSample', limit=minBands;
        case 'MinLeafSize', limit=max(1,minRows-1);
    end
    if space(j).Upper>limit
        space(j).Upper=limit;
        if ~isempty(progress), progress('message',sprintf('%s maximum adjusted to %d for the smallest training fold',space(j).Name,limit)); end
    end
    assert(space(j).Lower<=space(j).Upper,'SpectralML:SearchSpace', ...
        'The minimum for %s (%g) exceeds the fold limit %g. Reduce its minimum.', ...
        space(j).Name,space(j).Lower,limit);
    if ~isempty(space(j).Grid)
        space(j).Grid=space(j).Grid(space(j).Grid<=limit);
        assert(~isempty(space(j).Grid),'SpectralML:SearchSpace','Explicit grid has no valid values after fold-capacity check.');
    end
end
if strcmp(c.optimizer,'Grid'), [~,total]=parameterGrid(space,c.gridPoints); else, total=c.maxEvaluations; end
history=struct('iteration',{},'parameters',{},'score',{},'bestScore',{},'seconds',{},'status',{},'error',{});
bestLoss=Inf; best=struct; bestOOF=[]; bestFold=[]; timer=tic;
switch c.optimizer
    case 'Grid', gridSearch(space,c.gridPoints,@evaluate,cancel);
    case 'Random', randomSearch(space,c.maxEvaluations,c.seed+2000,@evaluate,cancel);
    case 'Bayesian', bayesianSearch(space,c.maxEvaluations,c.seed+2000,@evaluate,cancel);
end
assert(isfinite(bestLoss),'SpectralML:Optimization','All parameter evaluations failed. Inspect the search history/log.');
out=struct('bestParameters',best,'history',history,'oof',bestOOF,'foldScores',bestFold, ...
    'effectiveSearchSpace',space,'seconds',toc(timer),'totalPlanned',total);
    function loss=evaluate(candidate)
        checkCancelled(cancel); parameters=c.modelParams;
        names=fieldnames(candidate);
        for z=1:numel(names), parameters.(names{z})=candidate.(names{z}); end
        score=NaN; loss=NaN; status='failed'; message='';
        try
            [loss,score,oof,foldScores]=crossValidationObjective(cache,c,parameters,cancel);
            status='ok';
            if loss<bestLoss, bestLoss=loss; best=parameters; bestOOF=oof; bestFold=foldScores; end
        catch e
            if strcmp(e.identifier,'SpectralML:Cancelled'), rethrow(e); end
            message=e.message;
            if ~isempty(progress), progress('message',['Parameter evaluation failed: ' message]); end
        end
        bestScore=bestLoss; if strcmp(c.metric,'R2'), bestScore=-bestLoss; end
        if ~isfinite(bestScore), bestScore=NaN; end
        history(end+1)=struct('iteration',numel(history)+1,'parameters',parameters, ...
            'score',score,'bestScore',bestScore,'seconds',toc(timer),'status',status,'error',message);
        if ~isempty(progress)
            progress('optimization',struct('history',history,'total',total,'bestParameters',best));
        end
        checkCancelled(cancel);
    end
end
