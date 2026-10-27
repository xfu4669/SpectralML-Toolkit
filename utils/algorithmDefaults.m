function p = algorithmDefaults(group,method)
p = struct;
switch group
    case 'preprocessing'
        switch method
            case 'SG', p.window = 11; p.order = 2;
            case 'MSC', p.reference = 'mean';
            case {'FD','SD'}, p.window = 3; p.order = 2;
            case 'FOD', p.alpha = 0.5;
            case 'Detrend', p.order = 1;
            case 'MinMax', p.mode = 'sample'; p.lower = 0; p.upper = 1;
            case 'ZScore', p.mode = 'band';
        end
    case 'feature'
        switch method
            case 'VIP'
                p.components = 5; p.threshold = 1;
            case 'CARS'
                p.iterations = 50; p.sampleRatio = 0.8;
                p.components = 5; p.cvFolds = 5;
            case 'UVE'
                p.components = 5; p.noiseScale = 1e-6;
                p.noiseQuantile = 1;
            case 'SPA'
                p.minBands = 2; p.maxBands = 20;
                p.cvFolds = 5;
        end
end
end
