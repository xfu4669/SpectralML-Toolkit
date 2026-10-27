function [train,test] = kennardStone(X,~,ratio,~,cancel)
if nargin<5, cancel=[]; end
train=maxMinSelection(spectralDistances(X),round(size(X,1)*ratio),cancel);
test=setdiff(1:size(X,1),train);
end
