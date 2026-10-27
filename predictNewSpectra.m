function y = predictNewSpectra(bundleOrPath,X,wavelength)
% Load exported model.mat and apply exactly the fitted pipeline to new rows.
if ischar(bundleOrPath) || isstring(bundleOrPath)
    loaded=load(bundleOrPath,'bundle'); bundle=loaded.bundle;
else, bundle=bundleOrPath; end
assert(isreal(X) && all(isfinite(X(:))) && size(X,2)==numel(bundle.wavelength), ...
    'SpectralML:Prediction','Invalid new spectral matrix.');
assert(isequal(double(wavelength(:)'),double(bundle.wavelength(:)')), ...
    'SpectralML:Prediction','New wavelength coordinates/order must exactly match training.');
Z=preprocessSpectrum(X,wavelength,bundle.preprocessor.method,bundle.preprocessor.params,bundle.preprocessor);
y=predictRegression(bundle.model,Z(:,bundle.selection.indices));
end
