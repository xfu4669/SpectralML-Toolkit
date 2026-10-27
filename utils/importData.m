function d = importData(filename,options)
% Import without deleting rows or inventing wavelengths.
if nargin < 2, options = struct; end
options = withDefaults(options,struct('idColumn',1,'targetColumn',2, ...
    'spectralStartColumn',3,'wavelengths',[],'indexMode',false,'sheet',1));
[~,~,ext] = fileparts(filename);
assert(ismember(lower(ext),{'.csv','.xlsx','.xls'}), 'SpectralML:Import','Only CSV/XLSX/XLS are supported.');
% Read the original first row, before MATLAB can rename numeric/duplicate headers.
% Numeric Excel cells and numeric CSV header text both represent wavelengths.
if strcmpi(ext,'.csv')
    raw=readcell(filename,'FileType','text','Delimiter',',');
else
    raw=readcell(filename,'Sheet',options.sheet,'Range','A1');
end
assert(size(raw,1)>=2 && size(raw,2)>=3,'SpectralML:ImportLayout', ...
    'Use one header row, then sample ID, target, and spectral columns.');
headers=raw(1,:); body=raw(2:end,:);
n=size(body,1); p=size(body,2);
idx = [options.idColumn,options.targetColumn,options.spectralStartColumn];
assert(all(isfinite(idx)) && all(idx==fix(idx)) && all(idx>=1 & idx<=p), ...
    'SpectralML:ImportLayout','Column numbers must be positive integers within the data range.');
assert(options.idColumn~=options.targetColumn && max(idx(1:2))<idx(3), ...
    'SpectralML:ImportLayout','ID and target must be distinct columns before the spectral columns.');
d.id = sampleIDs(body(:,options.idColumn));
assert(~any(ismissing(d.id) | strlength(d.id)==0), 'SpectralML:Import','Missing sample ID.');
assert(numel(unique(d.id))==n, 'SpectralML:Import','Duplicate sample IDs: repeated observations must not cross train/test.');
d.y = numericColumn(body(:,options.targetColumn),'Target');
d.X = zeros(n,p-options.spectralStartColumn+1);
for j=options.spectralStartColumn:p
    d.X(:,j-options.spectralStartColumn+1) = numericColumn(body(:,j),sprintf('Spectral column %d',j));
end
names = headers(options.spectralStartColumn:end);
if options.indexMode
    d.wavelength = 1:size(d.X,2); d.wavelengthLabel = 'Band index (explicit selection)'; d.wavelengthSource='index';
elseif ~isempty(options.wavelengths)
    d.wavelength = double(options.wavelengths(:)'); d.wavelengthLabel = 'Wavelength (nm)'; d.wavelengthSource='specified';
else
    d.wavelength = cellfun(@headerWavelength,names); d.wavelengthLabel = 'Wavelength (nm)'; d.wavelengthSource='header';
    assert(all(isfinite(d.wavelength)), 'SpectralML:WavelengthRequired', ...
        'Use real wavelength headers such as 350 and 355, or specify wavelengths in import settings.');
end
assert(numel(d.wavelength)==size(d.X,2) && all(isfinite(d.wavelength)), ...
    'SpectralML:Import','Wavelength count must equal the spectral column count.');
assert(numel(unique(d.wavelength))==numel(d.wavelength), 'SpectralML:Import','Duplicate wavelengths.');
assert(all(diff(d.wavelength)>0), 'SpectralML:Import','Wavelengths must be strictly increasing; reorder columns in the source file.');
d.targetName = headerText(headers{options.targetColumn});
assert(~isempty(d.targetName),'SpectralML:ImportLayout','The target column needs a name in the first row.');
d.headers=cellfun(@headerText,headers,'UniformOutput',false);
d.filename = char(filename); d.importOptions = options;
validateInput(d);
end
function x = numericColumn(v,label)
if isnumeric(v), x = double(v);
elseif iscell(v), x=cellfun(@numericValue,v);
else, x = str2double(string(v)); end
assert(isvector(x) && isreal(x) && all(isfinite(x)), 'SpectralML:Import', ...
    '%s contains missing, nonnumeric, or infinite values.',label);
x = x(:);
end
function x=numericValue(v)
x=NaN;
if (isnumeric(v) || islogical(v)) && isscalar(v) && isreal(v)
    x=double(v);
elseif ischar(v) || (isstring(v) && isscalar(v))
    x=str2double(string(v));
    if ~isscalar(x) || ~isreal(x), x=NaN; end
end
end
function ids=sampleIDs(values)
ids=strings(numel(values),1);
for k=1:numel(values)
    v=values{k};
    if (isnumeric(v) || islogical(v)) && isscalar(v) && isreal(v) && isfinite(v)
        ids(k)=string(v);
    elseif ischar(v) || (isstring(v) && isscalar(v))
        text=strtrim(string(v));
        if ~isscalar(text), text=missing; end
        ids(k)=text;
    else
        ids(k)=missing;
    end
end
end
function value=headerWavelength(header)
value=NaN;
if isnumeric(header) && isscalar(header) && isreal(header)
    value=double(header); return;
end
text=headerText(header);
% Accept explicit wavelengths such as 350, 350.5, 350nm or 350 (nm).
% Do not infer wavelengths from identifiers such as B001 or Band1.
token=regexpi(text,'^([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)\s*(?:nm|\(\s*nm\s*\))?$','tokens','once');
if ~isempty(token), value=str2double(token{1}); end
end
function text=headerText(value)
text='';
if (isnumeric(value) || islogical(value)) && isscalar(value) && isreal(value) && isfinite(value)
    text=char(string(value));
elseif ischar(value) || (isstring(value) && isscalar(value))
    s=strtrim(string(value));
    if isscalar(s) && ~ismissing(s), text=char(s); end
end
end
