function [values,total] = parameterGrid(space,points)
values=cell(1,numel(space)); total=1;
for i=1:numel(space)
    s=space(i);
    if strcmp(s.Type,'categorical'), v=s.Values;
    else
        if ~isempty(s.Grid), x=s.Grid;
        elseif strcmp(s.Scale,'log'), x=logspace(log10(s.Lower),log10(s.Upper),points);
        else, x=linspace(s.Lower,s.Upper,points);
        end
        if strcmp(s.Type,'integer'), x=round(x); end
        v=num2cell(unique(x,'stable'));
    end
    values{i}=v; total=total*numel(v);
end
end
