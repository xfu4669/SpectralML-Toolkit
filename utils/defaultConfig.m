function c = defaultConfig
c.version = '1.0.0';
c.seed = 42; c.folds = 5; c.maxEvaluations = 30;
c.metric = 'RMSE'; c.gridPoints = 5; c.trainRatio = 0.8;
c.split = 'Random'; c.preprocessing = 'Raw'; c.feature = 'None';
c.model = 'PLSR'; c.optimizer = 'Bayesian';
c.preprocessParams = algorithmDefaults('preprocessing', c.preprocessing);
c.featureParams = algorithmDefaults('feature', c.feature);
[c.modelParams,c.searchSpace] = modelDefaults(c.model);
c.parameters = parameterCatalog(c);
end
