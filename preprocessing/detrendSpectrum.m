function Z = detrendSpectrum(X,w,order)
% Remove each spectrum's polynomial trend; no across-sample statistics are fitted.
w=double(w(:));
assert(order==fix(order) && order>=0 && order<numel(w), ...
    'SpectralML:Detrend','Polynomial order must be a nonnegative integer below the band count.');
t=(w-mean(w))/max(abs(w-mean(w)));
design=t.^(0:order); coefficients=design\X';
Z=X-(design*coefficients)';
end
