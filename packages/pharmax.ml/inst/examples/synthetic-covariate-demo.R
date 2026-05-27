# Purpose: Reproducible public demo for pharmax.ml 0.1.0-alpha
# Internal/exported: public example script

if (requireNamespace("pharmax.ml", quietly = TRUE)) {
  library(pharmax.ml)
} else if (requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all("packages/pharmax.ml", quiet = TRUE)
} else {
  stop("Install pharmax.ml or pkgload before running this demo.", call. = FALSE)
}

set.seed(2026)
n <- 120
demo <- data.frame(
  COV_WT = rnorm(n, 70, 10),
  COV_AGE = rnorm(n, 55, 12),
  COV_ALB = rnorm(n, 4.2, 0.4)
)
demo$ETA_CL <- 0.7 * scale(demo$COV_WT)[, 1] + rnorm(n, sd = 0.3)

quality <- px_data_quality(demo, impute = "median")
screen <- px_covariate(quality$data, method = "auto", n_top = 3)
intervals <- px_conformal(
  truth = demo$ETA_CL[1:80],
  prediction = demo$ETA_CL[1:80] + rnorm(80, sd = 0.2),
  new_prediction = c(-0.5, 0, 0.5),
  alpha = 0.1
)

print(quality)
print(screen)
print(intervals)
