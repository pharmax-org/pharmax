# Purpose: Distribution-free conformal prediction intervals
# Internal/exported: exported

#' Conformal prediction intervals
#'
#' @param truth Observed values in the calibration set.
#' @param prediction Predicted values in the calibration set.
#' @param new_prediction Predicted values for new observations.
#' @param alpha Miscoverage rate.
#' @param method Conformal method. `"split"` is fully implemented; `"cross"`
#'   and `"jackknife_plus"` return conservative split-style intervals in this
#'   public proof slice.
#' @return A tibble with predictions and conformal interval bounds.
#' @export
px_conformal <- function(truth,
                         prediction,
                         new_prediction,
                         alpha = 0.1,
                         method = c("split", "cross", "jackknife_plus")) {
  method <- match.arg(method)
  if (length(truth) != length(prediction)) {
    cli::cli_abort("{.arg truth} and {.arg prediction} must have the same length.")
  }
  if (alpha <= 0 || alpha >= 1) {
    cli::cli_abort("{.arg alpha} must be between 0 and 1.")
  }

  residual <- abs(truth - prediction)
  q <- stats::quantile(
    residual,
    probs = min(1, ceiling((length(residual) + 1) * (1 - alpha)) / length(residual)),
    na.rm = TRUE,
    names = FALSE,
    type = 1
  )

  tibble::tibble(
    prediction = new_prediction,
    lower = new_prediction - q,
    upper = new_prediction + q,
    alpha = alpha,
    method = method,
    interval_width = 2 * q
  )
}
