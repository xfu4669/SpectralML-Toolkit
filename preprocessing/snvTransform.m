function Z = snvTransform(X)
s=std(X,0,2);
assert(all(s>eps), 'SpectralML:SNV','SNV is undefined for a constant spectrum.');
Z=(X-mean(X,2))./s;
end
