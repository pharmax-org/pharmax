# Purpose: Synthetic benchmark data generation for pharmacometric ML workflows
# Internal/exported: exported

#' Simulate synthetic covariate benchmark data
#'
#' @param n Number of rows.
#' @param scenario Scenario: `"known_signal"`, `"no_signal"`, `"correlated"`, or `"missingness"`.
#' @param seed Random seed.
#' @param signal Signal strength for known-signal scenarios.
#' @param noise Residual noise standard deviation.
#' @return A data frame with `COV_` covariates and `ETA_` parameters.
#' @export
px_simulate_covariates <- function(n = 120L,
                                   scenario = c(
                                     "known_signal",
                                     "no_signal",
                                     "correlated",
                                     "missingness"
                                   ),
                                   seed = 2026L,
                                   signal = 0.75,
                                   noise = 0.30) {
  scenario <- match.arg(scenario)
  set.seed(seed)

  data <- data.frame(
    COV_WT = stats::rnorm(n, 70, 10),
    COV_AGE = stats::rnorm(n, 55, 12),
    COV_ALB = stats::rnorm(n, 4.2, 0.4),
    COV_SCR = stats::rlnorm(n, log(0.9), 0.25)
  )

  if (identical(scenario, "correlated")) {
    data$COV_BMI <- 0.75 * scaled_numeric(data$COV_WT) + stats::rnorm(n, sd = 0.45)
  } else {
    data$COV_BMI <- stats::rnorm(n, 27, 4)
  }

  if (identical(scenario, "no_signal")) {
    data$ETA_CL <- stats::rnorm(n, sd = 1)
    data$ETA_V <- stats::rnorm(n, sd = 1)
  } else {
    data$ETA_CL <- signal * scaled_numeric(data$COV_WT) + stats::rnorm(n, sd = noise)
    data$ETA_V <- 0.45 * scaled_numeric(data$COV_ALB) + stats::rnorm(n, sd = noise + 0.1)
  }

  if (identical(scenario, "missingness")) {
    miss_wt <- sample(seq_len(n), size = ceiling(n * 0.12))
    miss_alb <- sample(seq_len(n), size = ceiling(n * 0.08))
    data$COV_WT[miss_wt] <- NA_real_
    data$COV_ALB[miss_alb] <- NA_real_
  }

  attr(data, "pharmax_scenario") <- scenario
  attr(data, "pharmax_signal") <- if (identical(scenario, "no_signal")) NA_character_ else "COV_WT"
  data
}
