# Algorithm definitions

These notes describe the implementation and its numerical conventions. They do not establish benchmark performance. Release validation status is documented in the project README.

## Sample splitting

- **Random**: seeded permutation; the training count is `round(n * trainRatio)`.
- **KS**: Euclidean distances between raw spectra. Start with the most distant pair, then repeatedly choose the point with the largest minimum distance to the selected set. Bands are not standardized before splitting.
- **SPXY**: normalize the spectral and response distance matrices by their respective maxima, add them, and apply the same maximum-minimum selection rule. The response participates in this split.

KS and SPXY retain an n-by-n distance matrix and therefore require quadratic storage.

## Preprocessing

| Method | Definition |
| --- | --- |
| Raw | Identity transform |
| SG | Local polynomial smoothing on actual wavelength coordinates, including one-sided boundary windows |
| SNV | Per-spectrum centering and division by sample standard deviation |
| MSC | Per-spectrum intercept/slope correction against the training mean or median reference |
| FD / SD | Local polynomial first / second derivative; default three-point quadratic stencils |
| FOD | Caputo L1 fractional derivative, order 0–1; default 0.5 |
| Detrend | Subtract a polynomial trend fitted separately to each spectrum |
| Min-Max | Per-spectrum or training-fitted per-band range normalization |
| Z-score | Per-spectrum or training-fitted per-band standardization |

Per-band statistics and MSC references are fitted on training rows only. Validation, holdout, and new spectra reuse the saved state. Model-internal scaling is also fitted only on the corresponding training data.

See [Preprocessing and PCR](PREPROCESSING_PCR.md) for derivative formulas, boundary conventions, normalization defaults, and PCR details.

## Feature selection

Selectors receive the current training matrix and response, never holdout responses. Selected indices are sorted and mapped to original wavelength coordinates. PLS components are limited by the sample count, band count, and design-matrix rank.

- **None**: retain all wavelengths.
- **VIP**: fit PLS to standardized predictors and weight squared normalized loading weights by the response variance explained by each component. Retain scores at or above the configured threshold.
- **CARS**: Monte Carlo calibration subsets, standardized PLS coefficient weights, an exponentially decreasing band count, and weighted sampling without replacement. Select the candidate with the smallest fixed-fold PLS RMSE. This is an explicitly defined CARS variant, not a claim of equivalence to every published CARS package.
- **UVE**: append equally many small Gaussian noise variables and calculate leave-one-out PLS coefficient stability, `abs(mean(beta)) / std(beta)`. Compare true-variable stability with a chosen noise-stability quantile. The augmented matrix is not autoscaled again. This implementation is LOO UVE, not MCUVE.
- **SPA**: enumerate starting variables, grow successive orthogonal-projection chains, and choose the chain and length using fixed-fold OLS RMSE. Rank-deficient least squares use a pseudoinverse.

Zero selected bands produce an error rather than an automatic switch to another selector. SPA scores are selection indicators. CARS scores are the last available coefficient magnitudes for each band, not a common-model importance ranking across all bands. Candidate histories retain their own evaluation details.

## Regression

- **PLSR**: training-standardized predictors and `plsregress`.
- **PCR**: training-standardized predictors, SVD principal directions, then least-squares regression of centered responses on retained scores.
- **Ridge**: augmented least squares with an unpenalized intercept; no explicit matrix inverse.
- **SVR**: `fitrsvm`; choose one Gaussian or Linear kernel before searching numeric parameters. Gaussian is the default.
- **RF**: regression `TreeBagger` with bootstrap samples and random split predictors. Search tree count, minimum leaf size, and split predictor count.
- **XGBOOST**: custom exact greedy trees for squared-error loss with gradient `g = prediction - y`, Hessian `h = 1`, leaf weight `-G/(H+lambda)`, regularized gain, learning rate, and row/column subsampling. It does not provide the official library's histogram, missing-value, GPU, or distributed backends.
- **CNN**: two wavelength-direction convolution/ReLU blocks followed by a scalar regression output. Adam training uses CPU, a fixed seed, and training-only response standardization. If selected wavelengths are discontinuous, convolution follows their retained order rather than a constant physical spacing.

## Parameter search and validation

Grid search evaluates the complete Cartesian product. Random search samples the configured ranges. Bayesian search uses `bayesopt` with `expected-improvement-plus`. All candidates share the same folds and metric direction: minimize RMSE/MAE and maximize R².

Fold-local preprocessing and feature selection are cached because their settings remain fixed across model candidates. Validation rows do not participate in those fits. Each candidate records its parameters, score, running best, elapsed time, and errors. Failed candidates do not receive fabricated scores.

The final parameter set is refitted on the complete training set. CV metrics aggregate its out-of-fold predictions; search scores average per-fold metrics, so the numbers can differ. Reusing the tuning folds for reporting introduces selection bias and is not nested validation. The holdout is evaluated after selection.

## Metrics and diagnostics

Residuals are observed minus predicted. Reported rows are R², RMSE, RPD, RPIQ, MAE, and Bias. RPD uses sample SD; RPIQ uses Q75−Q25; Bias is mean residual. Undefined ratios are exported as NaN.

Residual histograms share Train/Test bin edges. Their vertical range follows actual count and empirical trend peaks. The residual-scatter shading is a bin-wise interquartile range, not a confidence interval. Spectral axes use actual wavelength bounds. Figures are exported as 300-dpi TIFF using MATLAB `exportgraphics`.