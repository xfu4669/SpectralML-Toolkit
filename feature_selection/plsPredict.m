function y = plsPredict(m,X)
y=[ones(size(X,1),1),(X-m.mean)./m.scale]*m.beta;
end
