# Installation and first run

## Source installation

1. On the repository page, choose **Code → Download ZIP**, then extract the archive.
2. Open MATLAB and set **Current Folder** to the extracted directory containing `startSpectralML.m`.
3. Run `startSpectralML` in the MATLAB Command Window.

No Python environment or package installation is required. The app uses a programmatic MATLAB UI; source editing takes place in the MATLAB editor.

## Toolboxes

| Configuration | Additional toolbox |
| --- | --- |
| PLSR, SVR, RF, wavelength selection, Bayesian search | Statistics and Machine Learning Toolbox |
| CNN | Deep Learning Toolbox |
| PCR or Ridge with None selection and Grid/Random search | No additional modeling toolbox |

MATLAB R2023a/R2023b are the intended source environments. Compatibility across releases has not been fully validated. This distribution contains source code and does not include an EXE installer.

## First analysis

Choose **Import data** and load `examples/example_spectra.csv`. Set **Random**, **Raw**, **None**, **Ridge**, and **Grid search**. In **Parameters**, set **Grid values / parameter** to `3`, then click **OK** and **Run analysis**.

The data example is synthetic. A first run checks how to operate the workflow; its scores are not a published benchmark.

## Common setup issues

- **Undefined function `startSpectralML`**: select the project root as Current Folder, or add that directory to the MATLAB path.
- **A required toolbox is missing**: choose a configuration with available dependencies or install the required toolbox through your MATLAB installation.
- **Wavelengths are not recognized**: use real numeric headers such as `350,355,360`, or provide explicit coordinates in the import dialog. Identifiers such as `B001` are not physical wavelengths.
- **No bands are selected**: review selector thresholds and component counts. VIP/UVE can legitimately retain no variables.
- **A search takes too long**: reduce search evaluations, grid values, or selector iterations. Complete grid size grows as the product of per-parameter choices.

Use **Export results** after a completed analysis. Select a writable output directory; a new timestamped subfolder holds data, models, settings, and TIFF figures. Cancellation is checked between supported computation and file-writing steps.
