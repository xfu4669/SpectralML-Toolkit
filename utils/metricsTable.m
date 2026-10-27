function t = metricsTable(r)
% Metrics occupy rows; the three data sets occupy columns, in UI/export order.
datasets={'Train','CV','Test'}; [keys,labels]=metricDefinitions;
values=nan(numel(keys),numel(datasets));
for k=1:numel(keys)
    for i=1:numel(datasets)
        if isempty(r), continue; end
        m=r.metrics.(datasets{i});
        if isfield(m,keys{k}), values(k,i)=m.(keys{k}); end
    end
end
t=table(labels(:),values(:,1),values(:,2),values(:,3), ...
    'VariableNames',{'Dataset','Train','CV','Test'});
end
