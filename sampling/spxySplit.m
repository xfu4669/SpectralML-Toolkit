function [train,test] = spxySplit(X,y,ratio,~,cancel)
if nargin<5, cancel=[]; end
dx=spectralDistances(X); dy=abs(y(:)-y(:)');
% Each distance matrix is divided by its own maximum, then summed.
dx=dx/max(max(dx(:)),eps); dy=dy/max(max(dy(:)),eps);
train=maxMinSelection(dx+dy,round(size(X,1)*ratio),cancel);
test=setdiff(1:size(X,1),train);
end
