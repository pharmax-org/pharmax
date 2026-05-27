# pharmax

[![R package checks](https://github.com/pharmax-org/pharmax/actions/workflows/r-package-check.yml/badge.svg)](https://github.com/pharmax-org/pharmax/actions/workflows/r-package-check.yml)
[![Site](https://img.shields.io/badge/site-pharmax--org.github.io%2Fpharmax-2f855a)](https://pharmax-org.github.io/pharmax/)

`pharmax` is an early public proof-slice for tidy, reproducible R workflows in
pharmacometrics.

The public repository currently contains three packages:

| Package | Public role |
|---|---|
| `pharmax` | Public package coordinator and status helper |
| `pharmax.viz` | Pharmacometric visualization helpers and gallery plots |
| `pharmax.ml` | R-native exploratory ML helpers for pharmacometric workflows |

## Status

This repository is intentionally conservative. It shows current public package
proof, not long-range company planning.

The packages are useful for exploratory analysis, package feedback, and public
examples. They are not validated for regulatory submission, autonomous
decision-making, clinical decision support, or production analysis control.

Possible future open-source candidates include core pharmacometric workflow
packages for PK, NCA, simulation, and data conventions. Those candidates are not
part of the current public package surface.

## Install

Install from GitHub:

```r
pak::pak("pharmax-org/pharmax/packages/pharmax")
pak::pak("pharmax-org/pharmax/packages/pharmax.viz")
pak::pak("pharmax-org/pharmax/packages/pharmax.ml")
```

Or install from a local clone:

```r
devtools::install("packages/pharmax")
devtools::install("packages/pharmax.viz")
devtools::install("packages/pharmax.ml")
```

## Quick Examples

Inspect the public package surface:

```r
library(pharmax)

px_public_packages()
px_public_status()
```

Create a pharmacometric visualization:

```r
library(pharmax.viz)

px_spaghetti(
  data.frame(
    ID = datasets::Theoph$Subject,
    TIME = datasets::Theoph$Time,
    DV = datasets::Theoph$conc
  )
)
```

Run an exploratory ML covariate screen on synthetic data:

```r
library(pharmax.ml)

set.seed(1)
pk_ml <- data.frame(
  ETA_CL = rnorm(80),
  COV_WT = rnorm(80, 70, 10),
  COV_AGE = rnorm(80, 55, 12)
)
pk_ml$ETA_CL <- 0.6 * scale(pk_ml$COV_WT)[, 1] + rnorm(80, sd = 0.3)

px_covariate(pk_ml, method = "auto", n_top = 3)
```

## R-Universe Status

The R-Universe registry configuration is maintained in
[`pharmax-org.r-universe.dev`](https://github.com/pharmax-org/pharmax-org.r-universe.dev)
for the current public packages.

## License

The current public packages are MIT licensed:

- `pharmax`
- `pharmax.viz`
- `pharmax.ml`

## Boundary

Internal planning, launch drafts, business strategy, and future product concepts
are kept outside this public repository.
