# METHOD_NOTES

Numerical definitions and parameter conventions for wavelength-aware preprocessing and principal component regression. See the project README for validation status.

## Methods and defaults

| Method | Parameters | Defaults |
| --- | --- | --- |
| FD | Window length; Polynomial order | 3; 2 |
| SD | Window length; Polynomial order | 3; 2 |
| FOD | Fractional order (0–1) | 0.5 |
| Detrend | Polynomial order | 1 |
| Min-Max | Normalization axis; Output minimum; Output maximum | Per spectrum; 0; 1 |
| Z-score | Normalization axis | Per band |
| PCR | Principal components, Minimum/Maximum | 1/15 |

The FOD order accepts the closed interval [0,1]. The UI constrains this input directly; configuration validation and the algorithm also check it. Changing a method preserves its own settings. The parameter window shows all adjustable methods together.

## FD and SD

At wavelength lambda_j, select an odd-length local window. Fit a polynomial to each spectrum using the actual offsets lambda-lambda_j, normalized by their maximum magnitude. The derivative equals the coefficient of the requested degree, multiplied by the degree factorial and divided by the coordinate scale to that degree.

The default window of three points and polynomial degree two produces centered interior and one-sided boundary stencils. Larger windows perform a local polynomial derivative directly. A degree-one derivative requires polynomial order >=1; degree two requires >=2. No wavelength points are removed or silently replaced by band indices.

## FOD: Caputo L1, order between zero and one

For 0 < alpha < 1, the definition is the left-sided Caputo derivative with its lower terminal at the first measured wavelength. On each interval, approximate the spectrum by a straight line. For the j-th wavelength:

```text
D^alpha f(lambda_j) = sum over k=1..j-1 of
  (f(lambda_(k+1))-f(lambda_k)) / (lambda_(k+1)-lambda_k)
  * ((lambda_j-lambda_k)^(1-alpha)
     -(lambda_j-lambda_(k+1))^(1-alpha)) / Gamma(2-alpha)
```

This is direct quadrature on the original wavelength intervals, including nonuniform spacing. The first output is zero for fractional orders, and a constant spectrum has zero fractional derivative. There is no hidden uniform-grid interpolation.

Endpoints are explicit software conventions: alpha=0 returns the original spectrum; alpha=1 uses the same three-point first-derivative formula as default FD. The alpha=0 identity is a separate endpoint convention; the limit of the positive-order Caputo formula as alpha approaches zero is f(lambda)-f(lambda_1).

The algorithm is Caputo L1, not a claim of numerical equivalence to a Grünwald–Letnikov implementation. The saved preprocessor records this definition. Its units depend on the wavelength unit; the importer uses nm when the source supplies actual wavelengths.

## Detrend

Scale wavelength coordinates, fit a polynomial separately to each row with a least-squares solve, and subtract the fitted trend. The polynomial order must be a nonnegative integer below the number of bands. No across-sample reference is fitted.

## Normalization

Min-Max maps the selected axis to the configured output minimum and maximum. Z-score subtracts the mean and divides by the sample standard deviation. `Per spectrum` uses only values in the same row; `Per band` fits parameters on training rows and reuses them for validation, test and new data.

For zero-range or zero-standard-deviation dimensions, the denominator is one. There is no clipping of held-out values to the requested Min-Max range. This keeps the transformation fixed after fitting. Saved preprocessing state includes all needed per-band statistics.

## PCR

Each model call fits a training-only mean and standard deviation, then decomposes the standardized design matrix Z = U S V'. Retain k principal directions. Regress the centered response on their scores using beta = S_k^(-1) U_k' (y-mean(y)); the implementation divides by singular values, without explicitly inverting a matrix.

Prediction is ((X-mean(X_train))/sd(X_train)) V_k beta + mean(y_train). Principal directions, response mean and regression coefficients are saved with the model. No test responses enter PCA or component selection.

Grid, random and Bayesian search use the existing shared folds. The component search upper bound is narrowed to the smallest fold's available rank and sample/band capacity. After selection, the full training pipeline is fitted again before test prediction. PCR itself uses base MATLAB SVD; selected feature-selection or optimization methods can still require their own toolboxes.

## Interface consistency

Controls, parameter names, chart captions, dataset labels and progress messages use English. Imported sample IDs, original target names, source headers and file paths are preserved. Plot style, real wavelength bounds and prediction diagnostics remain in the same workflow. Figures are exported only as 300-dpi TIFF files, with progress reporting and cancellation.
