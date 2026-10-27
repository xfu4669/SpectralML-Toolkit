function [idx,score,history] = cars(X,y,p,seed,cancel)
% CARS variant: MC calibration, exponential decay, weighted sampling without replacement,
% and fixed-fold PLS RMSE selection. Coefficients are in standardized feature units.
n=size(X,1); bands=size(X,2); N=p.iterations;
folds=makeFolds(n,p.cvFolds,seed+11);
sampleCount=max(3,min(n,floor(p.sampleRatio*n)));
active=1:bands; best=Inf; idx=[]; score=zeros(bands,1);
history=struct('iteration',{},'count',{},'rmse',{},'indices',{});
for t=1:N
    checkCancelled(cancel);
    rows=randperm(n,sampleCount); m=plsFit(X(rows,active),y(rows),p.components);
    weights=abs(m.beta(2:end)); score(active)=weights;
    target=max(1,round(bands*(min(2,bands)/bands)^((t-1)/max(1,N-1))));
    target=min(target,numel(active));
    keys=-log(max(rand(numel(active),1),realmin))./max(weights,eps);
    [~,order]=sort(keys); active=sort(active(order(1:target)));
    loss=selectorCV(X(:,active),y,folds,p.components,'PLS',cancel);
    history(t)=struct('iteration',t,'count',numel(active),'rmse',loss,'indices',active);
    if loss<best, best=loss; idx=active; end
end
end
