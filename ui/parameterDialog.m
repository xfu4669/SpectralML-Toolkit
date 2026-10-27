function [result,accepted] = parameterDialog(owner,c,data)
% One scrollable editor for every algorithm, with transactional saving.
result=c; accepted=false; catalog=parameterCatalog(c); options=toolkitOptions;
preMethods=parameterMethods(catalog.preprocessing,options.preprocessing);
featureMethods=parameterMethods(catalog.features,options.features);
preHeights=pairedHeights(catalog.preprocessing,preMethods);
featureHeights=pairedHeights(catalog.features,featureMethods);
models=options.models; modelHeights=cell(1,numel(models));
for k=1:numel(models), modelHeights{k}=modelPanelHeight(catalog.models.(models{k})); end
position=owner.Position;
position=[position(1)+(position(3)-1120)/2,position(2)+(position(4)-820)/2,1120,820];
win=uifigure('Name','Parameters','Position',position,'WindowStyle','modal','Color',[0.97 0.98 0.99]);
win.CloseRequestFcn=@(~,~)delete(win);
root=uigridlayout(win,[2 1]); root.RowHeight={'1x',48}; root.Padding=[18 16 18 16]; root.RowSpacing=14;
body=uigridlayout(root,[6+numel(models),1]); body.Scrollable='on'; body.Padding=[0 0 14 0]; body.RowSpacing=12;
body.RowHeight=[{210,34,sum([preHeights{:}])+14*(numel(preHeights)-1), ...
    34,sum([featureHeights{:}])+14*(numel(featureHeights)-1),34},modelHeights];

general=uipanel(body,'Title','General','FontSize',20,'FontWeight','bold','BackgroundColor','w');
gg=uigridlayout(general,[3 4]); gg.ColumnWidth={220,'1x',220,'1x'};
gg.RowHeight=repmat({44},1,3); gg.Padding=[16 12 16 12]; gg.ColumnSpacing=16; gg.RowSpacing=8;
uilabel(gg,'Text','Random seed'); seed=uieditfield(gg,'numeric','Value',c.seed);
uilabel(gg,'Text','CV folds'); folds=uieditfield(gg,'numeric','Value',c.folds);
uilabel(gg,'Text','Search evaluations'); count=uieditfield(gg,'numeric','Value',c.maxEvaluations);
uilabel(gg,'Text','Grid values / parameter'); points=uieditfield(gg,'numeric','Value',c.gridPoints, ...
    'Tooltip','Grid search only. Range 1 to 9 with 3 values tries 1, 5, 9. Parameter values are combined.');
uilabel(gg,'Text','Objective'); metric=uidropdown(gg,'Items',{'RMSE','MAE','R²'},'ItemsData',{'RMSE','MAE','R2'},'Value',c.metric);

sectionTitle(body,'Preprocessing');
preGrid=uigridlayout(body,[numel(preHeights),2]); preGrid.ColumnWidth={'1x','1x'};
preGrid.RowHeight=preHeights; preGrid.Padding=[0 0 0 0]; preGrid.ColumnSpacing=14; preGrid.RowSpacing=14;
preEditors=struct;
for item=preMethods
    name=item{1}; index=find(strcmp(options.preprocessing,name),1);
    panel=uipanel(preGrid,'Title',options.preprocessingLabels{index},'FontSize',20,'FontWeight','bold','BackgroundColor','w');
    preEditors.(name)=parameterEditor(panel,catalog.preprocessing.(name),1);
end

sectionTitle(body,'Feature selection');
featureGrid=uigridlayout(body,[numel(featureHeights),2]); featureGrid.ColumnWidth={'1x','1x'};
featureGrid.RowHeight=featureHeights; featureGrid.Padding=[0 0 0 0]; featureGrid.RowSpacing=14; featureGrid.ColumnSpacing=14;
featureEditors=struct;
for item=featureMethods
    name=item{1}; panel=uipanel(featureGrid,'Title',name,'FontSize',20,'FontWeight','bold','BackgroundColor','w');
    featureEditors.(name)=parameterEditor(panel,catalog.features.(name),1);
end

sectionTitle(body,'Regression models');
modelEditors=struct;
for k=1:numel(models)
    name=models{k}; settings=catalog.models.(name);
    panel=uipanel(body,'Title',name,'FontSize',20,'FontWeight','bold','BackgroundColor','w');
    fixedCount=numel(fieldnames(settings.fixed));
    categoryCount=nnz(strcmp({settings.space.Type},'categorical'));
    extraHeights={};
    if categoryCount>0, extraHeights{end+1}=54*categoryCount; end
    if fixedCount>0, extraHeights{end+1}=editorHeight(fixedCount,2); end
    g=uigridlayout(panel,[1+numel(extraHeights),1]); g.RowHeight=[{'1x'},extraHeights];
    g.Padding=[12 10 12 10]; g.RowSpacing=12;
    table=uitable(g,'Data',numericSpaceCells(settings.space), ...
        'ColumnName',{'Parameter','Minimum','Maximum'},'ColumnEditable',[false true true], ...
        'ColumnWidth',{320,240,'auto'},'RowName',[],'FontSize',18);
    categories=struct;
    if categoryCount>0
        [~,~,supported]=modelDefaults(name);
        categories=categoricalEditor(g,settings.space,supported);
    end
    controls=struct;
    if fixedCount>0, controls=parameterEditor(g,settings.fixed,2); end
    modelEditors.(name)=struct('table',table,'fixed',controls,'categories',categories);
end

buttons=uigridlayout(root,[1 4]); buttons.ColumnWidth={150,'1x',130,130}; buttons.Padding=[0 0 0 0]; buttons.ColumnSpacing=12;
uibutton(buttons,'Text','Reset defaults','BackgroundColor','w','ButtonPushedFcn',@restore);
cancel=uibutton(buttons,'Text','Cancel','BackgroundColor','w','ButtonPushedFcn',@(~,~)delete(win)); cancel.Layout.Column=3;
confirmButton=uibutton(buttons,'Text','OK','BackgroundColor',[0.14 0.39 0.67],'FontColor','w','FontWeight','bold', ...
    'ButtonPushedFcn',@confirm); confirmButton.Layout.Column=4;
applyUIFonts(win,18);
uiwait(win);

    function restore(~,~)
        defaults=defaultConfig; fresh=parameterCatalog(defaults);
        seed.Value=defaults.seed; folds.Value=defaults.folds; count.Value=defaults.maxEvaluations;
        points.Value=defaults.gridPoints; metric.Value=defaults.metric;
        for method=preMethods
            key=method{1}; writeParameters(preEditors.(key),fresh.preprocessing.(key));
        end
        for method=featureMethods
            key=method{1}; writeParameters(featureEditors.(key),fresh.features.(key));
        end
        for method=models
            key=method{1}; modelEditors.(key).table.Data=numericSpaceCells(fresh.models.(key).space);
            writeCategories(modelEditors.(key).categories,fresh.models.(key).space);
            writeParameters(modelEditors.(key).fixed,fresh.models.(key).fixed);
        end
    end
    function confirm(~,~)
        try
            next=c; next.seed=seed.Value; next.folds=folds.Value; next.maxEvaluations=count.Value;
            next.gridPoints=points.Value; next.metric=metric.Value;
            edited=catalog;
            for method=preMethods
                key=method{1}; edited.preprocessing.(key)=readParameters(preEditors.(key),catalog.preprocessing.(key));
            end
            for method=featureMethods
                key=method{1}; edited.features.(key)=readParameters(featureEditors.(key),catalog.features.(key));
            end
            for method=models
                key=method{1}; fixed=readParameters(modelEditors.(key).fixed,catalog.models.(key).fixed);
                space=readSpace(modelEditors.(key).table.Data,catalog.models.(key).space,modelEditors.(key).categories);
                edited.models.(key)=struct('fixed',fixed,'space',space);
            end
            next.parameters=edited;
            next.preprocessParams=edited.preprocessing.(next.preprocessing);
            next.featureParams=edited.features.(next.feature);
            next.modelParams=edited.models.(next.model).fixed;
            next.searchSpace=edited.models.(next.model).space;
            validateAllParameters(next);
            validateConfig(next,data);
            result=next; accepted=true; delete(win);
        catch e
            uialert(win,e.message,'Invalid parameters','Interpreter','none');
        end
    end
end

function sectionTitle(parent,title)
uilabel(parent,'Text',title,'FontSize',22,'FontWeight','bold');
end

function controls=parameterEditor(parent,p,pairs)
keys=fieldnames(p); rows=max(1,ceil(numel(keys)/pairs));
g=uigridlayout(parent,[rows,2*pairs]); g.Padding=[14 10 14 10]; g.ColumnSpacing=12; g.RowSpacing=8;
g.RowHeight=repmat({44},1,rows); g.ColumnWidth=repmat({220,'1x'},1,pairs);
controls=struct;
for k=1:numel(keys)
    name=keys{k}; uilabel(g,'Text',parameterLabel(name));
    if strcmp(name,'alpha')
        control=uieditfield(g,'numeric','Value',p.(name),'Limits',[0 1]);
    elseif isnumeric(p.(name))
        control=uieditfield(g,'numeric','Value',p.(name));
    elseif strcmp(name,'reference')
        control=uidropdown(g,'Items',{'Mean','Median'},'ItemsData',{'mean','median'},'Value',p.(name));
    elseif strcmp(name,'mode')
        control=uidropdown(g,'Items',{'Per spectrum','Per band'},'ItemsData',{'sample','band'},'Value',p.(name));
    else
        control=uieditfield(g,'text','Value',char(string(p.(name))));
    end
    controls.(name)=control;
end
end

function p=readParameters(controls,template)
p=template; names=fieldnames(template);
for k=1:numel(names), name=names{k}; p.(name)=controls.(name).Value; end
end

function writeParameters(controls,p)
names=fieldnames(p);
for k=1:numel(names), name=names{k}; controls.(name).Value=p.(name); end
end

function cells=numericSpaceCells(space)
numeric=space(~strcmp({space.Type},'categorical'));
cells=cell(numel(numeric),3);
for k=1:numel(numeric)
    s=numeric(k); cells(k,:)={parameterLabel(s.Name),s.Lower,s.Upper};
end
end

function controls=categoricalEditor(parent,space,supported)
rows=find(strcmp({space.Type},'categorical'));
g=uigridlayout(parent,[numel(rows),1]); g.Padding=[0 0 0 0]; g.RowHeight=repmat({44},1,numel(rows));
controls=struct;
for k=rows(:)'
    s=space(k); choices=supported.(s.Name);
    row=uigridlayout(g,[1 2]); row.ColumnWidth={220,'1x'}; row.Padding=[0 0 0 0];
    uilabel(row,'Text',parameterLabel(s.Name));
    labels=cellfun(@optionLabel,choices,'UniformOutput',false);
    controls.(s.Name)=uidropdown(row,'Items',labels,'ItemsData',choices, ...
        'Value',singleChoice(choices,s.Values));
end
end

function writeCategories(controls,space)
for k=1:numel(space)
    if ~strcmp(space(k).Type,'categorical'), continue; end
    item=controls.(space(k).Name);
    item.Value=singleChoice(item.ItemsData,space(k).Values);
end
end

function value=singleChoice(choices,saved)
% Older configurations with both kernels selected open with the default Gaussian kernel.
value=choices{1};
if numel(saved)==1 && ismember(saved{1},choices), value=saved{1}; end
end

function label=optionLabel(value)
switch value
    case 'gaussian', label='Gaussian';
    case 'linear', label='Linear';
    otherwise, label=value;
end
end

function space=readSpace(cells,space,categories)
row=0;
for k=1:numel(space)
    if strcmp(space(k).Type,'categorical')
        item=categories.(space(k).Name);
        space(k).Values={item.Value};
    else
        row=row+1;
        space(k).Lower=asNumber(cells{row,2}); space(k).Upper=asNumber(cells{row,3});
    end
    % GUI searches generate their numeric choices from the visible bounds.
    % Scale remains the algorithm's saved/default internal search convention.
    space(k).Grid=[];
end
end

function n=asNumber(value)
if isnumeric(value), n=value; else, n=str2double(string(value)); end
end

function validateAllParameters(c)
% Check syntax for every saved algorithm without imposing data-specific limits
% on methods that are not currently selected.
validateConfig(c);
options=toolkitOptions;
for item=options.preprocessing
    name=item{1}; probe=c; probe.preprocessing=name; probe.preprocessParams=c.parameters.preprocessing.(name);
    try, validateConfig(probe); catch e, error('SpectralML:Parameters','%s: %s',name,e.message); end
end
for item=options.features
    name=item{1}; probe=c; probe.feature=name; probe.featureParams=c.parameters.features.(name);
    try, validateConfig(probe); catch e, error('SpectralML:Parameters','%s: %s',name,e.message); end
end
for item=options.models
    name=item{1}; probe=c; probe.model=name;
    probe.modelParams=c.parameters.models.(name).fixed; probe.searchSpace=c.parameters.models.(name).space;
    try, validateConfig(probe); catch e, error('SpectralML:Parameters','%s: %s',name,e.message); end
end
end

function label=parameterLabel(name)
switch name
    case 'window', label='Window length';
    case 'order', label='Polynomial order';
    case 'reference', label='Reference spectrum';
    case 'alpha', label='Fractional order (0–1)';
    case 'mode', label='Normalization axis';
    case 'lower', label='Output minimum';
    case 'upper', label='Output maximum';
    case {'components','Components'}, label='PLS components';
    case 'NumComponents', label='Principal components';
    case 'threshold', label='VIP threshold';
    case 'iterations', label='Sampling iterations';
    case 'sampleRatio', label='Sampling fraction';
    case 'cvFolds', label='Internal CV folds';
    case 'noiseScale', label='Noise amplitude';
    case 'noiseQuantile', label='Noise quantile';
    case 'minBands', label='Minimum bands';
    case 'maxBands', label='Maximum bands';
    case 'Lambda', label='Regularization';
    case 'BoxConstraint', label='Box constraint C';
    case 'KernelScale', label='Kernel width';
    case 'Epsilon', label='Epsilon';
    case 'Kernel', label='Kernel function';
    case 'NumTrees', label='Number of trees';
    case 'MinLeafSize', label='Minimum leaf size';
    case 'NumPredictorsToSample', label='Split predictors';
    case 'MaxDepth', label='Maximum depth';
    case 'LearnRate', label='Learning rate';
    case 'Gamma', label='Split penalty';
    case 'Subsample', label='Row sampling fraction';
    case 'Colsample', label='Column sampling fraction';
    case 'NumFilters', label='Number of filters';
    case 'Epochs', label='Training epochs';
    case 'MiniBatchSize', label='Mini-batch size';
    case 'KernelSize', label='Kernel size';
    case 'L2Regularization', label='L2 regularization';
    otherwise, label=name;
end
end

function methods=parameterMethods(group,available)
methods={};
for item=available
    if ~isempty(fieldnames(group.(item{1}))), methods{end+1}=item{1}; end %#ok<AGROW>
end
end
function heights=pairedHeights(group,methods)
heights=cell(1,ceil(numel(methods)/2));
for row=1:numel(heights)
    height=0;
    for k=2*row-1:min(2*row,numel(methods))
        height=max(height,30+editorHeight(numel(fieldnames(group.(methods{k}))),1));
    end
    heights{row}=height;
end
end
function height=editorHeight(count,pairs)
rows=max(1,ceil(count/pairs)); height=20+44*rows+8*(rows-1);
end
function height=modelPanelHeight(settings)
categories=nnz(strcmp({settings.space.Type},'categorical'));
numeric=numel(settings.space)-categories; fixed=numel(fieldnames(settings.fixed));
height=98+34*numeric;
if categories>0, height=height+54*categories+12; end
if fixed>0, height=height+editorHeight(fixed,2)+12; end
height=max(148,height);
end
