function Z = derivativeSpectrum(X,w,degree,p)
% Local polynomial derivatives on actual (possibly nonuniform) wavelengths.
% Default 3-point quadratic stencils give centered interior and one-sided edges.
w=double(w(:)'); bands=size(X,2);
assert(numel(w)==bands && all(diff(w)>0),'SpectralML:Derivative','Wavelengths must be aligned and increasing.');
assert(ismember(degree,[1 2]) && p.window==fix(p.window) && mod(p.window,2)==1 && ...
    p.window>=3 && p.window<=bands && p.order==fix(p.order) && p.order>=degree && p.order<p.window, ...
    'SpectralML:Derivative','Use an odd window within the band count and a polynomial order >= derivative order and < window.');
Z=zeros(size(X)); half=floor(p.window/2);
for j=1:bands
    start=max(1,min(j-half,bands-p.window+1)); indices=start:start+p.window-1;
    offsets=w(indices)-w(j); scale=max(abs(offsets)); offsets=offsets/scale;
    design=offsets(:).^(0:p.order); inverse=pinv(design);
    weights=factorial(degree)*inverse(degree+1,:)'/scale^degree;
    Z(:,j)=X(:,indices)*weights;
end
end
