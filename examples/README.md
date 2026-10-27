# Examples

`example_spectra.csv` contains 80 synthetic samples and 61 bands spanning 400–1600 nm. Column 1 contains sample IDs, column 2 contains the response, and later column headers contain wavelengths.

The file is intended for learning the interface and exercising the pipeline. It is not experimental data and does not establish scientific performance.

To run a compact command-line example from the project root:

```matlab
addpath(genpath(pwd));
result = demoSpectralML;
```

`makeExampleData` optionally generates another synthetic CSV/XLSX pair. Generated values are not guaranteed to match the supplied CSV exactly.
