function plotPredictionDiagnostics(axes,r,subset)
if nargin<3, subset='All'; end
assert(numel(axes)==3,'SpectralML:Plot','Prediction diagnostics require three axes.');
plotResidualHistogram(axes(1),r,subset);
plotResidualScatter(axes(2),r,subset);
plotPrediction(axes(3),r,subset,false);
end
