function [p,s,choices] = modelDefaults(method)
% Search ranges may be narrowed by the smallest CV training fold.
p = struct; choices = struct;
s = struct('Name',{},'Type',{},'Lower',{},'Upper',{},'Scale',{},'Values',{},'Grid',{});
switch method
    case 'PLSR'
        add('Components','integer',1,15,'linear',{});
    case 'PCR'
        add('NumComponents','integer',1,15,'linear',{});
    case 'Ridge'
        add('Lambda','real',1e-6,1e3,'log',{});
    case 'SVR'
        add('BoxConstraint','real',0.01,1000,'log',{});
        add('KernelScale','real',0.01,100,'log',{});
        add('Epsilon','real',0.001,1,'log',{});
        choices.Kernel={'gaussian','linear'};
        add('Kernel','categorical',NaN,NaN,'linear',{'gaussian'});
    case 'RF'
        add('NumTrees','integer',50,300,'linear',{});
        add('MinLeafSize','integer',1,10,'linear',{});
        add('NumPredictorsToSample','integer',1,30,'linear',{});
    case 'XGBOOST'
        add('NumTrees','integer',50,250,'linear',{});
        add('MaxDepth','integer',2,6,'linear',{});
        add('LearnRate','real',0.01,0.3,'log',{});
        add('Lambda','real',0.01,10,'log',{});
        p.Gamma = 0; p.Subsample = 0.8; p.Colsample = 0.8; p.MinLeafSize = 3;
    case 'CNN'
        add('NumFilters','integer',4,24,'linear',{});
        add('LearnRate','real',1e-4,0.01,'log',{});
        add('Epochs','integer',20,100,'linear',{});
        p.MiniBatchSize = 16; p.KernelSize = 5; p.L2Regularization = 1e-4;
    otherwise, error('SpectralML:Model','Unsupported model: %s',method);
end
    function add(name,type,lo,hi,scale,values)
        s(end+1) = struct('Name',name,'Type',type,'Lower',lo,'Upper',hi, ...
            'Scale',scale,'Values',{values},'Grid',[]);
    end
end
