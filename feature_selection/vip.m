function [idx,score,details] = vip(X,y,p)
m=plsFit(X,y,p.components);
W=m.stats.W; W=W./max(sqrt(sum(W.^2,1)),eps);
explained=sum(m.XS.^2,1).*sum(m.YL.^2,1);
assert(sum(explained)>eps, 'SpectralML:VIP','No target variance explained by PLS.');
score=sqrt(size(X,2)*(W.^2*explained')/sum(explained));
idx=find(score>=p.threshold);
details=struct('threshold',p.threshold,'componentsUsed',m.components);
end
