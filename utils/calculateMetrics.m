function m = calculateMetrics(y,pred)
y = y(:); pred = pred(:);
assert(~isempty(y) && numel(y)==numel(pred) && isreal(y) && isreal(pred) && all(isfinite(y)) && all(isfinite(pred)), ...
    'SpectralML:Metrics','Invalid observed values or predictions.');
e = y-pred; sst = sum((y-mean(y)).^2);
m.R2 = NaN; if sst>0, m.R2 = 1-sum(e.^2)/sst; end
m.RMSE = sqrt(mean(e.^2)); m.MAE = mean(abs(e));
m.MSE = mean(e.^2); m.Bias = mean(e); m.N = numel(y);
m.RPD = NaN;
% Sample standard deviation, denominator n-1. Undefined for constant y or zero RMSE.
if numel(y)>1 && std(y,0)>0 && m.RMSE>0, m.RPD = std(y,0)/m.RMSE; end
m.RPIQ = NaN;
quartiles=quantile(y,[0.25 0.75]); spread=quartiles(2)-quartiles(1);
if m.RMSE>0, m.RPIQ=spread/m.RMSE; end
m.SEP=NaN;
if numel(y)>1, m.SEP=sqrt(sum((e-m.Bias).^2)/(numel(y)-1)); end
m.r=NaN; yc=y-mean(y); pc=pred-mean(pred);
denominator=sqrt(sum(yc.^2)*sum(pc.^2));
if denominator>0, m.r=max(-1,min(1,sum(yc.*pc)/denominator)); end
m.MAPE=NaN;
if all(y~=0), m.MAPE=100*mean(abs(e./y)); end
end
