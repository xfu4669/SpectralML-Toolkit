function Z = sgSmooth(X,w,window,order)
% Local polynomial SG smoothing using actual wavelength offsets, including edges.
assert(window==fix(window) && mod(window,2)==1 && window>=3 && window<=size(X,2), ...
    'SpectralML:SG','SG window must be odd, >=3 and <= number of bands.');
assert(order==fix(order) && order>=0 && order<window, 'SpectralML:SG','SG polynomial order must be below window length.');
p=size(X,2); Z=zeros(size(X)); h=floor(window/2);
for j=1:p
    start=max(1,min(j-h,p-window+1)); idx=start:start+window-1;
    t=w(idx)-w(j); t=t/max(max(abs(t)),eps);
    A=t(:).^(0:order); weights=pinv(A);
    Z(:,j)=X(:,idx)*weights(1,:)';
end
end
