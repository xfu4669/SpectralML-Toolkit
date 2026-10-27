function y = predictXGBoost(m,X)
y=repmat(m.base,size(X,1),1);
for i=1:numel(m.trees), y=y+m.learningRate*predictXGBoostTree(m.trees{i},X); end
end
