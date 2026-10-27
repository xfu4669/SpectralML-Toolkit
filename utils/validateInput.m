function validateInput(d)
assert(isnumeric(d.X) && isreal(d.X) && all(isfinite(d.X(:))), 'SpectralML:Data','Spectra must be finite real numeric values.');
assert(size(d.X,1)>=8 && size(d.X,2)>=2, 'SpectralML:Data','At least 8 samples and 2 bands are required.');
assert(numel(d.y)==size(d.X,1) && all(isfinite(d.y)) && isreal(d.y), 'SpectralML:Data','Invalid target values.');
assert(numel(d.id)==numel(d.y) && numel(unique(d.id))==numel(d.id), 'SpectralML:Data','Sample IDs must be unique and aligned.');
assert(std(d.y)>0, 'SpectralML:Data','The target is constant; regression evaluation is undefined.');
assert(numel(d.wavelength)==size(d.X,2) && all(isfinite(d.wavelength)) && all(diff(d.wavelength)>0), ...
    'SpectralML:Data','Wavelengths must be finite, aligned and strictly increasing.');
end
