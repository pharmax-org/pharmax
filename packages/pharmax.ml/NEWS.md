# pharmax.ml 0.3.0-public

- Trimmed the public package to defensible R-native exploratory helpers.
- Kept covariate screening, conformal intervals, bootstrap uncertainty, data
  quality summaries, explainability, ensembles, synthetic covariate benchmarks,
  calibration summaries, and bounded evidence reports.
- Removed deferred product and advanced modeling surfaces from the public
  package.

# pharmax.ml 0.2.0-alpha

- Added `px_simulate_covariates()` for reproducible synthetic benchmark datasets.
- Added `px_benchmark_covariate()` for repeated known-signal and stress-test
  scenarios.
- Added `px_calibrate_conformal()` for empirical coverage and interval-width
  summaries.
- Added `px_ml_report()` for structured exploratory decision-support evidence.
- Added covariate-screening context metadata for seed, method, parameters,
  covariates, package version, and creation time.
- Added benchmark tests and an evidence-focused vignette.

# pharmax.ml 0.1.0-alpha

- Added R-native covariate screening with `px_covariate()`.
- Added conformal prediction intervals with `px_conformal()`.
- Added data-quality summaries and median imputation with `px_data_quality()`.
- Added permutation explainability with `px_explain()`.
- Added ensemble prediction helper with `px_ensemble()`.
- Added a synthetic known-signal demo.
