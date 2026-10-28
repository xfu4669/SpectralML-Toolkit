# Installation and first run

## Windows application

When a standalone Windows package is provided, double-click
`SpectralML_Toolkit_1_0_1_Setup.exe` and follow the installation wizard. Open the
application using its installed shortcut. Full MATLAB, a MATLAB license, Python,
and manually adding source folders to a path are not required on the recipient's
computer.

This is an installer, not a dependency-free portable EXE. The R2023a build uses
MATLAB Runtime R2023a. The web installer downloads Runtime if required, so first
installation needs an Internet connection and can take several minutes. An
offline installer must include the matching Runtime instead. See the
[MathWorks installer documentation](https://www.mathworks.com/help/compiler/compiler.package.installer.html).

Generated installers live under `dist/windows/<build timestamp>/`. They are
excluded from Git source tracking and can be distributed as separate release
downloads. Compiling a package does not establish that it has been tested on
another computer.

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

MATLAB R2023a/R2023b are the intended source environments. Compatibility across releases has not been fully validated. Source downloads do not automatically contain the separately generated Windows installer.

## Build the Windows installer

On 64-bit Windows, use MATLAB R2023a with MATLAB Compiler, Statistics and Machine
Learning Toolbox, and Deep Learning Toolbox to include all supported models.
Select the source directory in MATLAB and run:

```matlab
buildWindowsApp('web')
```

The command compiles `launchSpectralML.m` as a Windows application without a
console window and creates an installer. It includes the synthetic CSV example,
quick-start instructions, and the project license. Only application source
folders are explicitly bundled; tests, exported analyses, local notes, and old
build output are not part of the application archive.

For an offline installer, first obtain the matching Runtime installer using
`compiler.runtime.download`, then run `buildWindowsApp('installer')`. This option
produces a much larger download. Keep the build source in an English path if a
compiler reports path or directory permission errors with non-ASCII paths.

The build command does not open the app or execute its analysis tests. Functional
checks and installation on a clean recipient computer remain separate steps.

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
