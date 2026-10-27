function options = toolkitOptions
% Canonical method IDs shared by UI, validation, and saved parameter catalogs.
options.preprocessing={'Raw','SG','SNV','MSC','FD','SD','FOD','Detrend','MinMax','ZScore'};
options.preprocessingLabels={'Raw','SG','SNV','MSC','FD','SD','FOD','Detrend','Min-Max','Z-score'};
options.features={'None','CARS','VIP','UVE','SPA'};
options.models={'PLSR','PCR','Ridge','SVR','RF','XGBOOST','CNN'};
end
