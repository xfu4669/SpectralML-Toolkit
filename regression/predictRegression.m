function y = predictRegression(m,X)
Z=(X-m.mean)./m.scale;
switch m.method
    case 'PLSR', y=[ones(size(Z,1),1),Z]*m.core;
    case 'PCR', y=Z*m.loadings*m.core+m.yMean;
    case 'Ridge', y=Z*m.core+m.yMean;
    case {'SVR','RF'}, y=predict(m.core,Z);
    case 'XGBOOST', y=predictXGBoost(m.core,Z);
    case 'CNN'
        y=predict(m.core,reshape(single(Z'),[size(Z,2) 1 1 size(Z,1)]), ...
            'ExecutionEnvironment','cpu');
        y=double(y(:))*m.yScale+m.yMean;
end
y=double(y(:));
assert(all(isfinite(y)), 'SpectralML:Prediction','Model produced nonfinite predictions.');
end
