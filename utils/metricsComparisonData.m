function cells = metricsComparisonData(r)
% Cell text uses char values for compatibility with MATLAB UI tables.
cells=table2cell(metricsTable(r));
for row=1:size(cells,1)
    for column=2:size(cells,2)
        value=cells{row,column};
        if ~isfinite(value), text='—';
        elseif value~=0 && (abs(value)<0.001 || abs(value)>=1e4), text=sprintf('%.2e',value);
        else, text=sprintf('%.4g',value);
        end
        cells{row,column}=text;
    end
end
end
