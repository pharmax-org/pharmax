# pharmax.ml

`pharmax.ml` provides R-native machine learning helpers for exploratory
pharmacometric workflows.

This public release is intended for exploratory decision support, method
prototyping, and package feedback. It is not validated for autonomous clinical
decision-making or regulatory submission.

## What Is Included

- `px_covariate()` for covariate screening with random forest, lasso, adaptive
  lasso, elastic net, and correlation methods
- `px_conformal()` for distribution-free prediction intervals
- `px_bootstrap_uq()` for bootstrap uncertainty summaries
- `px_explain()` for permutation, partial-dependence, and ICE-style explainability
- `px_data_quality()` for missingness, outlier summaries, and simple imputation
- `px_ensemble()` for weighted prediction ensembles
- `px_simulate_covariates()` for synthetic covariate benchmark datasets
- `px_benchmark_covariate()` for repeated known-signal and stress-test scenarios
- `px_calibrate_conformal()` for interval coverage summaries
- `px_ml_report()` for bounded, human-reviewed evidence summaries

## Install Locally

Install from GitHub:

```r
pak::pak("pharmax-org/pharmax/packages/pharmax.ml")
```

Or install from a local clone:

```r
devtools::install("packages/pharmax.ml")
```

## Covariate Screening Quickstart

```r
library(pharmax.ml)

set.seed(1)
data <- data.frame(
  ETA_CL = rnorm(80),
  COV_WT = rnorm(80, 70, 10),
  COV_AGE = rnorm(80, 55, 12)
)
data$ETA_CL <- 0.6 * scale(data$COV_WT)[, 1] + rnorm(80, sd = 0.3)

px_covariate(data, method = "auto", n_top = 3)
```

## Conformal Prediction Quickstart

```r
px_conformal(
  truth = c(1, 2, 3, 4),
  prediction = c(1.1, 1.8, 3.1, 3.9),
  new_prediction = c(2, 5),
  alpha = 0.1
)
```

## Benchmark And Evidence Quickstart

```r
demo <- px_simulate_covariates(scenario = "known_signal")
quality <- px_data_quality(demo, impute = "median")
screen <- px_covariate(quality$data, method = "auto", n_top = 3)
calibration <- px_calibrate_conformal(
  truth = demo$ETA_CL[1:40],
  lower = demo$ETA_CL[1:40] - 0.5,
  upper = demo$ETA_CL[1:40] + 0.5,
  prediction = demo$ETA_CL[1:40],
  alpha = 0.1
)

px_ml_report(screen, quality = quality, calibration = calibration)
```

Use outputs as documented, human-reviewed evidence. Do not use this alpha release
as an autonomous decision system.
