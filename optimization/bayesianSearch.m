function bayesianSearch(space,count,seed,evaluate,cancel)
saved=rng; cleanup=onCleanup(@()rng(saved)); rng(seed,'twister'); %#ok<NASGU>
vars=optimizableVariable.empty; fixed=struct;
for j=1:numel(space)
    s=space(j);
    if strcmp(s.Type,'categorical')
        if numel(s.Values)==1, fixed.(s.Name)=s.Values{1}; continue; end
        v=optimizableVariable(s.Name,s.Values,'Type','categorical');
    else
        if s.Lower==s.Upper, fixed.(s.Name)=s.Lower; continue; end
        transform='none'; if strcmp(s.Scale,'log'), transform='log'; end
        v=optimizableVariable(s.Name,[s.Lower,s.Upper],'Type',s.Type,'Transform',transform);
    end
    vars(end+1)=v; %#ok<AGROW>
end
if isempty(vars), evaluate(fixed); return; end
bayesopt(@objective,vars,'MaxObjectiveEvaluations',count, ...
    'IsObjectiveDeterministic',true,'AcquisitionFunctionName','expected-improvement-plus', ...
    'UseParallel',false,'PlotFcn',[],'Verbose',0,'OutputFcn',@stop);
checkCancelled(cancel);
    function loss=objective(t)
        p=fixed;
        for i=1:width(t)
            value=t{1,i};
            if iscell(value), value=value{1}; end
            if iscategorical(value) || isstring(value), value=char(value); end
            p.(t.Properties.VariableNames{i})=value;
        end
        loss=evaluate(p);
    end
    function halt=stop(~,~)
        drawnow limitrate; halt=~isempty(cancel) && cancel();
    end
end
