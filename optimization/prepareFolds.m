function cache = prepareFolds(X,y,w,c,cancel,progress)
% Fit each entire pipeline on its own training fold exactly once. The cache is
% reused across hyperparameter candidates because preprocessing/selection settings
% do not vary during model optimization. Validation rows never enter fitting.
ids=makeFolds(numel(y),c.folds,c.seed); cache=cell(c.folds,1);
for k=1:c.folds
    checkCancelled(cancel); a=find(ids~=k); b=find(ids==k);
    [A,state]=preprocessSpectrum(X(a,:),w,c.preprocessing,c.preprocessParams);
    B=preprocessSpectrum(X(b,:),w,c.preprocessing,c.preprocessParams,state);
    f=selectFeatures(A,y(a),w,c.feature,c.featureParams,c.seed+k,cancel);
    cache{k}=struct('XTrain',A(:,f.indices),'XValid',B(:,f.indices), ...
        'yTrain',y(a),'yValid',y(b),'trainRows',a,'validRows',b, ...
        'preprocessor',state,'selection',f);
    if ~isempty(progress), progress('message',sprintf('CV: fitted preprocessing and selection for fold %d/%d',k,c.folds)); end
end
end
