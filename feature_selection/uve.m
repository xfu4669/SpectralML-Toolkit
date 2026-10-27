function [idx,score,details] = uve(X,y,p,cancel)
% Leave-one-out coefficient stability with equally many tiny random noise variables.
[n,b]=size(X);
mu=mean(X,1); sd=std(X,0,1); sd(sd<eps)=1;
Z=(X-mu)./sd; noise=p.noiseScale*randn(n,b);
A=[Z,noise]; coeff=zeros(n,2*b);
for i=1:n
    checkCancelled(cancel); rows=true(n,1); rows(i)=false;
    % Do NOT autoscale augmented noise: this would destroy the tiny-noise UVE definition.
    k=min([p.components,n-2,2*b,rank(A(rows,:)-mean(A(rows,:),1))]);
    assert(k>=1,'SpectralML:UVE','Insufficient rank for UVE.');
    [~,~,~,~,beta]=plsregress(A(rows,:),y(rows),k);
    coeff(i,:)=beta(2:end)';
end
stability=abs(mean(coeff,1))./max(std(coeff,0,1),eps);
threshold=quantile(stability(b+1:end),p.noiseQuantile);
score=stability(1:b)'; idx=find(score>threshold);
details=struct('threshold',threshold,'noiseStability',stability(b+1:end)', ...
    'definition','LOO PLS coefficient mean / sample SD; no autoscaling of injected noise');
end
