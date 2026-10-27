function cells = metricsDisplayData(r,dataset)
% Plain char cells keep UI tables compatible with MATLAB R2023a.
[keys,labels]=metricDefinitions; cells=cell(numel(keys),2);
for k=1:numel(keys)
    value=NaN;
    if ~isempty(r) && isfield(r.metrics.(dataset),keys{k}), value=r.metrics.(dataset).(keys{k}); end
    if ~isfinite(value), text='—';
    elseif strcmp(keys{k},'N'), text=sprintf('%d',value);
    else, text=sprintf('%.5g',value);
    end
    cells(k,:)={labels{k},text};
end
end
