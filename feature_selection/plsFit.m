function m = plsFit(X,y,components)
% Train-only scaling; centered constant bands are harmless but an all-constant fold is not.
m.mean=mean(X,1); m.scale=std(X,0,1); m.scale(m.scale<eps)=1;
Z=(X-m.mean)./m.scale;
k=min([components,size(X,1)-1,size(X,2),rank(Z)]);
assert(k>=1, 'SpectralML:PLS','PLS needs a nonconstant training matrix.');
[m.XL,m.YL,m.XS,~,m.beta,~,~,m.stats]=plsregress(Z,y,k);
m.components=k;
end
