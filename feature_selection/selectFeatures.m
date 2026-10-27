function f = selectFeatures(X,y,w,method,p,seed,cancel)
if nargin<7, cancel=[]; end
saved=rng; cleanup=onCleanup(@()rng(saved)); rng(seed,'twister'); %#ok<NASGU>
checkCancelled(cancel);
f=struct('method',method,'indices',[],'wavelengths',[],'scores',[], ...
    'history',[],'details',struct);
switch method
    case 'None', f.indices=1:size(X,2);
    case 'VIP', [f.indices,f.scores,f.details]=vip(X,y,p);
    case 'CARS', [f.indices,f.scores,f.history]=cars(X,y,p,seed,cancel);
    case 'UVE', [f.indices,f.scores,f.details]=uve(X,y,p,cancel);
    case 'SPA', [f.indices,f.scores,f.history]=spa(X,y,p,seed,cancel);
    otherwise, error('SpectralML:Feature','Unsupported selector: %s',method);
end
f.indices=sort(unique(f.indices(:)'));
assert(~isempty(f.indices), 'SpectralML:NoFeatures', ...
    '%s selected no bands. Adjust its threshold/parameters; no fallback was silently applied.',method);
f.wavelengths=w(f.indices);
end
