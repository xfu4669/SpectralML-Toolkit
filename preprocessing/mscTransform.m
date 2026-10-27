function Z = mscTransform(X,reference)
assert(std(reference)>eps, 'SpectralML:MSC','MSC reference spectrum is constant.');
A=[ones(numel(reference),1),reference(:)]; coeff=A\X';
assert(all(abs(coeff(2,:))>1e-12), 'SpectralML:MSC','MSC encountered a zero scatter slope.');
Z=(X-coeff(1,:)')./coeff(2,:)';
end
