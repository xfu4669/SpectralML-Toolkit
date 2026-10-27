function validateConfig(c,d)
% Runtime guards used by both GUI and command-line entry points.
integer(c.seed,0,2^32-1,'Seed'); integer(c.folds,3,1000,'CV folds');
integer(c.maxEvaluations,1,100000,'Search evaluations'); integer(c.gridPoints,2,1000,'Grid points');
assert(ismember(c.split,{'Random','KS','SPXY'}),'SpectralML:Config','Unsupported split.');
options=toolkitOptions;
assert(ismember(c.preprocessing,options.preprocessing),'SpectralML:Config','Unsupported preprocessing.');
assert(ismember(c.feature,{'None','CARS','VIP','UVE','SPA'}),'SpectralML:Config','Unsupported selector.');
assert(ismember(c.optimizer,{'Grid','Random','Bayesian'}),'SpectralML:Config','Unsupported optimizer.');
assert(ismember(c.metric,{'RMSE','MAE','R2'}),'SpectralML:Config','Unsupported metric.');
assert(isscalar(c.trainRatio) && isfinite(c.trainRatio) && c.trainRatio>0 && c.trainRatio<1, ...
    'SpectralML:Config','Training ratio must be between 0 and 1.');
p=c.preprocessParams;
if ismember(c.preprocessing,{'SG','FD','SD'})
    minimumOrder=0;
    if strcmp(c.preprocessing,'FD'), minimumOrder=1; elseif strcmp(c.preprocessing,'SD'), minimumOrder=2; end
    integer(p.window,3,Inf,'Window length'); integer(p.order,minimumOrder,p.window-1,'Polynomial order');
    assert(mod(p.window,2)==1,'SpectralML:Config','Window length must be odd.');
elseif strcmp(c.preprocessing,'MSC')
    assert(ismember(p.reference,{'mean','median'}),'SpectralML:Config','MSC reference must be mean or median.');
elseif strcmp(c.preprocessing,'FOD')
    assert(isnumeric(p.alpha) && isscalar(p.alpha) && isfinite(p.alpha) && p.alpha>=0 && p.alpha<=1, ...
        'SpectralML:Config','Fractional order must be between 0 and 1.');
elseif strcmp(c.preprocessing,'Detrend')
    integer(p.order,0,Inf,'Polynomial order');
elseif ismember(c.preprocessing,{'MinMax','ZScore'})
    assert(ismember(p.mode,{'sample','band'}),'SpectralML:Config','Normalization axis must be sample or band.');
    if strcmp(c.preprocessing,'MinMax')
        assert(isnumeric(p.lower) && isscalar(p.lower) && isfinite(p.lower) && ...
            isnumeric(p.upper) && isscalar(p.upper) && isfinite(p.upper) && p.upper>p.lower, ...
            'SpectralML:Config','Output maximum must be greater than output minimum.');
    end
end
p=c.featureParams;
if isfield(p,'components'), integer(p.components,1,Inf,'PLS components'); end
if isfield(p,'cvFolds'), integer(p.cvFolds,3,1000,'Selector CV folds'); end
switch c.feature
    case 'VIP', positive(p.threshold,'VIP threshold',true);
    case 'CARS'
        integer(p.iterations,2,100000,'CARS iterations'); unit(p.sampleRatio,'CARS sample ratio');
    case 'UVE'
        positive(p.noiseScale,'UVE noise scale',false); unit(p.noiseQuantile,'UVE noise quantile');
    case 'SPA'
        integer(p.minBands,1,Inf,'SPA min bands'); integer(p.maxBands,p.minBands,Inf,'SPA max bands');
end
[defaults,expected,choices]=modelDefaults(c.model);
assert(isequal(sort(fieldnames(c.modelParams)),sort(fieldnames(defaults))), ...
    'SpectralML:Config','Fixed model parameter names do not match this model.');
assert(numel(c.searchSpace)==numel(expected) && isequal({c.searchSpace.Name},{expected.Name}), ...
    'SpectralML:Config','Search parameter names/order must match this model.');
for i=1:numel(c.searchSpace)
    s=c.searchSpace(i);
    assert(strcmp(s.Type,expected(i).Type),'SpectralML:Config','Parameter type cannot be changed: %s',s.Name);
    assert(ismember(s.Scale,{'linear','log'}),'SpectralML:Config','Scale must be linear or log.');
    if strcmp(s.Type,'categorical')
        assert(iscell(s.Values) && numel(s.Values)==1 && isfield(choices,s.Name) && ...
            all(ismember(s.Values,choices.(s.Name))), ...
            'SpectralML:Config','Select exactly one valid option for %s.',s.Name);
    else
        positive(s.Lower,s.Name,false); positive(s.Upper,s.Name,false);
        assert(s.Upper>=s.Lower,'SpectralML:Config','Maximum is below minimum: %s',s.Name);
        if strcmp(s.Type,'integer')
            integer(s.Lower,1,Inf,s.Name); integer(s.Upper,1,Inf,s.Name);
        end
        if ~isempty(s.Grid)
            assert(isnumeric(s.Grid) && isvector(s.Grid) && all(isfinite(s.Grid)) && all(s.Grid>=s.Lower & s.Grid<=s.Upper), ...
                'SpectralML:Config','Explicit grid values must lie in the parameter range: %s',s.Name);
            if strcmp(s.Type,'integer'), assert(all(s.Grid==fix(s.Grid)),'SpectralML:Config','Integer grid required.'); end
        end
    end
end
p=c.modelParams;
if strcmp(c.model,'XGBOOST')
    positive(p.Gamma,'Gamma',true); unit(p.Subsample,'Subsample'); unit(p.Colsample,'Colsample');
    integer(p.MinLeafSize,1,Inf,'Min leaf size');
elseif strcmp(c.model,'CNN')
    integer(p.MiniBatchSize,1,Inf,'Mini batch size'); integer(p.KernelSize,1,Inf,'Kernel size');
    positive(p.L2Regularization,'L2 regularization',true);
end
if nargin>1 && ~isempty(d)
    validateInput(d); n=round(numel(d.y)*c.trainRatio);
    assert(n>=6 && numel(d.y)-n>=2,'SpectralML:Config','Need >=6 training samples and >=2 test samples.');
    assert(c.folds<=floor(n/2),'SpectralML:Config','Too many CV folds for the training sample count.');
    inner=n-ceil(n/c.folds);
    if isfield(c.featureParams,'cvFolds')
        assert(c.featureParams.cvFolds<=floor(inner/2),'SpectralML:Config', ...
            'Selector CV folds exceed the smallest outer training fold capacity.');
    end
    if ismember(c.preprocessing,{'SG','FD','SD'})
        assert(c.preprocessParams.window<=size(d.X,2),'SpectralML:Config','Window length exceeds the band count.');
    elseif strcmp(c.preprocessing,'Detrend')
        assert(c.preprocessParams.order<size(d.X,2),'SpectralML:Config','Detrend order must be below the band count.');
    elseif strcmp(c.preprocessing,'FOD') && c.preprocessParams.alpha==1
        assert(size(d.X,2)>=3,'SpectralML:Config','Order-1 differentiation needs at least three bands.');
    end
end
end
function integer(x,lo,hi,label)
assert(isnumeric(x) && isscalar(x) && isfinite(x) && x==fix(x) && x>=lo && x<=hi, ...
    'SpectralML:Config','%s must be an integer in [%g,%g].',label,lo,hi);
end
function positive(x,label,zeroAllowed)
assert(isnumeric(x) && isscalar(x) && isfinite(x) && (x>0 || (zeroAllowed && x==0)), ...
    'SpectralML:Config','%s has an invalid numeric value.',label);
end
function unit(x,label)
positive(x,label,false); assert(x<=1,'SpectralML:Config','%s must be <=1.',label);
end
