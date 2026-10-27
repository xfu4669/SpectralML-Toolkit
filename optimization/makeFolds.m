function id = makeFolds(n,k,seed)
assert(k==fix(k) && k>=3 && k<=floor(n/2), 'SpectralML:CV', ...
    'CV folds must be >=3 and <=floor(training samples/2), so each validation fold has >=2 samples.');
s=RandStream('mt19937ar','Seed',seed); order=randperm(s,n);
id=zeros(n,1); id(order)=mod(0:n-1,k)+1;
end
