function Z = fractionalDerivative(X,w,alpha)
% Left-sided Caputo derivative, L1 quadrature on actual wavelength intervals.
% Alpha=0 is explicitly defined as identity; alpha=1 uses a first derivative.
assert(isnumeric(alpha) && isscalar(alpha) && isfinite(alpha) && alpha>=0 && alpha<=1, ...
    'SpectralML:FOD','Fractional order must be between 0 and 1.');
w=double(w(:)');
assert(numel(w)==size(X,2) && all(diff(w)>0),'SpectralML:FOD','Wavelengths must be aligned and increasing.');
if alpha==0, Z=X; return; end
if alpha==1
    Z=derivativeSpectrum(X,w,1,struct('window',3,'order',2)); return;
end
% On each interval f' is constant. Integrate (lambda-s)^(-alpha) analytically.
slopes=diff(X,1,2)./diff(w); Z=zeros(size(X)); factor=gamma(2-alpha);
for j=2:numel(w)
    left=w(j)-w(1:j-1); right=w(j)-w(2:j);
    weights=(left.^(1-alpha)-right.^(1-alpha))/factor;
    Z(:,j)=slopes(:,1:j-1)*weights(:);
end
end
