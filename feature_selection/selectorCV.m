function loss = selectorCV(X,y,foldId,components,base,cancel)
pred=nan(size(y));
for k=1:max(foldId)
    checkCancelled(cancel); a=foldId~=k; b=~a;
    if strcmp(base,'PLS')
        m=plsFit(X(a,:),y(a),components); pred(b)=plsPredict(m,X(b,:));
    else
        mu=mean(X(a,:),1); sd=std(X(a,:),0,1); sd(sd<eps)=1;
        A=[ones(nnz(a),1),(X(a,:)-mu)./sd];
        beta=pinv(A)*y(a);
        pred(b)=[ones(nnz(b),1),(X(b,:)-mu)./sd]*beta;
    end
end
loss=sqrt(mean((pred-y).^2));
end
