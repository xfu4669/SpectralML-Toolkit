function m = trainRegression(X,y,method,p,seed,cancel)
if nargin<6, cancel=[]; end
checkCancelled(cancel);
saved=rng; cleanup=onCleanup(@()rng(saved)); rng(seed,'twister'); %#ok<NASGU>
m=struct('method',method,'parameters',p,'mean',mean(X,1),'scale',std(X,0,1));
m.scale(m.scale<eps)=1; Z=(X-m.mean)./m.scale;
switch method
    case 'PLSR'
        k=min([p.Components,size(Z,1)-1,size(Z,2),rank(Z)]);
        assert(k>=1,'SpectralML:PLS','PLSR needs nonconstant predictors.');
        [~,~,~,~,m.core]=plsregress(Z,y,k); m.componentsUsed=k;
    case 'PCR'
        % PCA is fitted to these training rows only. Regress y on retained scores.
        [U,S,V]=svd(Z,'econ'); singular=diag(S);
        tolerance=max(size(Z))*eps(max(singular)); available=sum(singular>tolerance);
        k=min([p.NumComponents,available,size(Z,1)-1,size(Z,2)]);
        assert(k>=1,'SpectralML:PCR','PCR requires at least one nonconstant principal component.');
        m.loadings=V(:,1:k); m.yMean=mean(y);
        m.core=(U(:,1:k)'*(y-m.yMean))./singular(1:k);
        m.componentsUsed=k; m.explainedVariance=singular(1:k).^2/sum(singular.^2);
    case 'Ridge'
        m.yMean=mean(y);
        % Stable augmented least squares; intercept is not regularized.
        m.core=[Z;sqrt(p.Lambda)*eye(size(Z,2))]\[y-m.yMean;zeros(size(Z,2),1)];
    case 'SVR'
        m.core=fitrsvm(Z,y,'KernelFunction',p.Kernel,'KernelScale',p.KernelScale, ...
            'BoxConstraint',p.BoxConstraint,'Epsilon',p.Epsilon,'Standardize',false);
    case 'RF'
        m.core=TreeBagger(p.NumTrees,Z,y,'Method','regression', ...
            'MinLeafSize',p.MinLeafSize,'NumPredictorsToSample',min(p.NumPredictorsToSample,size(Z,2)), ...
            'OOBPrediction','off','Options',statset('UseParallel',false));
    case 'XGBOOST'
        m.core=trainXGBoost(Z,y,p,cancel);
    case 'CNN'
        assert(exist('trainNetwork','file')==2,'SpectralML:Dependency','CNN requires Deep Learning Toolbox.');
        m.yMean=mean(y); m.yScale=std(y); if m.yScale<eps, m.yScale=1; end
        b=size(Z,2); kernel=min(p.KernelSize,b);
        layers=[imageInputLayer([b 1 1],'Normalization','none','Name','spectrum')
            convolution2dLayer([kernel 1],p.NumFilters,'Padding','same','Name','conv1')
            reluLayer('Name','relu1')
            convolution2dLayer([kernel 1],p.NumFilters,'Padding','same','Name','conv2')
            reluLayer('Name','relu2')
            fullyConnectedLayer(1,'Name','prediction')
            regressionLayer('Name','loss')];
        options=trainingOptions('adam','InitialLearnRate',p.LearnRate, ...
            'MaxEpochs',p.Epochs,'MiniBatchSize',min(p.MiniBatchSize,size(Z,1)), ...
            'L2Regularization',p.L2Regularization,'ExecutionEnvironment','cpu', ...
            'Shuffle','every-epoch','Verbose',false,'Plots','none','OutputFcn',@stopTraining);
        m.core=trainNetwork(reshape(single(Z'),[b 1 1 size(Z,1)]),single((y-m.yMean)/m.yScale),layers,options);
        checkCancelled(cancel);
    otherwise, error('SpectralML:Model','Unsupported model: %s',method);
end
checkCancelled(cancel);
    function stop=stopTraining(~)
        drawnow limitrate; stop=~isempty(cancel) && cancel();
    end
end
