# pharmax.viz

`pharmax.viz` provides pharmacometric visualization helpers for the pharmax
ecosystem.

This public release includes:

- `theme_pharmax()` for clean light/dark ggplot2 themes
- `px_spaghetti()` for individual concentration-time profiles
- `px_gof()` for four-panel goodness-of-fit diagnostics
- `px_residuals()` for residual diagnostics
- `px_vpc()` for lightweight visual predictive checks
- `px_npde()` for NPDE-style diagnostics
- `px_forest()` for parameter and covariate effect forest plots
- `px_plot_grid()` for composing Pharmax plots
- `px_save()` for publication-ready plot export

## Status

This package is ready for exploratory feedback. It is not a validated reporting
tool for regulatory submission.

## Install Locally

Install from GitHub:

```r
pak::pak("pharmax-org/pharmax/packages/pharmax.viz")
```

Or install from a local clone:

```r
devtools::install("packages/pharmax.viz")
```

## Theophylline Example

```r
library(ggplot2)
library(pharmax.viz)

theoph <- datasets::Theoph

px_spaghetti(
  data.frame(
    ID = theoph$Subject,
    TIME = theoph$Time,
    DV = theoph$conc
  )
)
```

## Goodness-Of-Fit Example

```r
px_gof(
  data.frame(
    DV = c(5, 8, 6, 3, 1),
    PRED = c(4.5, 7.5, 5.8, 3.2, 1.1),
    IPRED = c(5.1, 8.2, 5.9, 2.9, 0.9),
    CWRES = c(0.2, -0.4, 0.1, 0.3, -0.2),
    TIME = c(0.5, 1, 2, 4, 8)
  )
)
```

## Diagnostic Gallery Example

```r
demo <- data.frame(
  TIME = rep(c(0.5, 1, 2, 4, 8), each = 20),
  DV = abs(rnorm(100, 4, 1)),
  PRED = abs(rnorm(100, 4.1, 0.9)),
  SIM = abs(rnorm(100, 4.2, 1.1)),
  CWRES = rnorm(100),
  NPDE = rnorm(100)
)

px_plot_grid(
  px_residuals(demo),
  px_npde(demo),
  title = "Public/synthetic diagnostic review"
)

px_vpc(demo, bins = 5)
```
