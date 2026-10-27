function catalog = parameterCatalog(c)
% All algorithms retain their own settings; active fields remain the run API.
catalog=struct('preprocessing',struct,'features',struct,'models',struct);
options=toolkitOptions;
for item=options.preprocessing
    name=item{1}; catalog.preprocessing.(name)=algorithmDefaults('preprocessing',name);
end
for item=options.features
    name=item{1}; catalog.features.(name)=algorithmDefaults('feature',name);
end
for item=options.models
    name=item{1}; [fixed,space]=modelDefaults(name);
    catalog.models.(name)=struct('fixed',fixed,'space',space);
end
if isfield(c,'parameters')
    groups=fieldnames(catalog);
    for g=1:numel(groups)
        group=groups{g};
        if ~isfield(c.parameters,group), continue; end
        names=fieldnames(catalog.(group));
        for j=1:numel(names)
            name=names{j};
            if isfield(c.parameters.(group),name)
                catalog.(group).(name)=c.parameters.(group).(name);
            end
        end
    end
end
catalog.preprocessing.(c.preprocessing)=c.preprocessParams;
catalog.features.(c.feature)=c.featureParams;
catalog.models.(c.model)=struct('fixed',c.modelParams,'space',c.searchSpace);
end
