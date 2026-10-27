function [idx,score,history] = spa(X,y,p,seed,cancel)
% Enumerate starting variables, grow chains by successive orthogonal projection,
% select chain length with fixed-fold OLS RMSE. Rank-deficient OLS uses SVD pseudoinverse.
[n,b]=size(X); mu=mean(X,1); sd=std(X,0,1); sd(sd<eps)=1;
Z=(X-mu)./sd; maxBands=min([p.maxBands,b,n-2]); minBands=min(p.minBands,maxBands);
folds=makeFolds(n,p.cvFolds,seed+23);
best=Inf; idx=[]; score=zeros(b,1);
history=struct('start',{},'count',{},'rmse',{},'indices',{}); h=0;
for start=1:b
    checkCancelled(cancel); R=Z; chain=start;
    for k=1:maxBands
        if k>=minBands
            loss=selectorCV(X(:,chain),y,folds,1,'OLS',cancel);
            h=h+1; history(h)=struct('start',start,'count',k,'rmse',loss,'indices',chain);
            if loss<best, best=loss; idx=chain; end
        end
        if k==maxBands, break; end
        v=R(:,chain(end)); denom=v'*v;
        if denom>eps, R=R-v*(v'*R)/denom; end
        norms=sum(R.^2,1); norms(chain)=-Inf;
        [~,next]=max(norms); chain(end+1)=next;
    end
end
score(idx)=1;
end
