function checkDependencies(c)
needsStats=ismember(c.model,{'PLSR','SVR','RF'}) || ~strcmp(c.feature,'None') || strcmp(c.optimizer,'Bayesian');
if needsStats
    assert(exist('plsregress','file')==2 && license('test','Statistics_Toolbox'), ...
        'SpectralML:Dependency','This configuration requires Statistics and Machine Learning Toolbox.');
end
if strcmp(c.model,'CNN')
    assert(exist('trainNetwork','file')==2 && license('test','Neural_Network_Toolbox'), ...
        'SpectralML:Dependency','CNN requires Deep Learning Toolbox.');
end
end
