function values = parseNumberList(textValue)
% Safe numeric list/range parser; never evaluates MATLAB expressions.
s=strtrim(char(string(textValue)));
if isempty(s), values=[]; return; end
if contains(s,':')
    parts=strsplit(s,':'); v=str2double(parts);
    assert((numel(v)==2 || numel(v)==3) && all(isfinite(v)), ...
        'SpectralML:Parameters','Numeric range must be start:end or start:step:end.');
    if numel(v)==2, first=v(1); step=1; last=v(2); else, first=v(1); step=v(2); last=v(3); end
    assert(step~=0 && (last-first)/step>=0 && (last-first)/step<=1e6, ...
        'SpectralML:Parameters','Invalid or excessively long numeric range.');
    values=first:step:last;
else
    parts=regexp(s,'[,;\s]+','split'); values=str2double(parts);
    assert(all(isfinite(values)),'SpectralML:Parameters','Use only numeric values separated by commas or spaces.');
end
end
