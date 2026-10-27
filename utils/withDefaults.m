function s = withDefaults(s,defaults)
names = fieldnames(defaults);
for i=1:numel(names)
    if ~isfield(s,names{i}), s.(names{i}) = defaults.(names{i}); end
end
end
