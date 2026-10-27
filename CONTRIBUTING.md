# Contributing

Bug reports, documentation improvements, and focused pull requests are welcome.

For a bug report, include the MATLAB release, operating system, selected methods, relevant parameter settings, and the full error message. Include a small synthetic or anonymized input when possible.

For code changes:

- Keep the sample split, preprocessing, selection, model, and plotting modules separate.
- Fit sample-dependent transforms and selectors only on the corresponding training rows.
- Preserve saved-model prediction compatibility, or document any format change.
- Document the numerical definition and dependencies of a new algorithm.
- Add a meaningful regression test when changing numerical behavior, and report which tests were actually run.

Run the existing test suite from the project root:

```matlab
addpath(genpath(pwd));
results = runtests('tests/test_spectralml.m');
table(results)
```

Keep generated analysis results, compiler outputs, local notes, and temporary files out of source changes. Include the applicable license and attribution when incorporating third-party code.
