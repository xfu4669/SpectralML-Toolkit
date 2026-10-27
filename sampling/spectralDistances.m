function D = spectralDistances(X)
% Euclidean distance on raw spectra, no feature scaling.
z = sum(X.^2,2); D = sqrt(max(0,z+z'-2*(X*X')));
D(1:size(D,1)+1:end) = 0;
end
