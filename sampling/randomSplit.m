function [train,test] = randomSplit(X,~,ratio,seed)
s = RandStream('mt19937ar','Seed',seed);
order = randperm(s,size(X,1)); n = round(size(X,1)*ratio);
train = sort(order(1:n)); test = sort(order(n+1:end));
end
