# Purpose: Calibration summaries for conformal prediction intervals
# Internal/exported: exported

#' Calibrate conformal interval coverage
#'
#' @param truth Observed values.
#' @param lower Lower interval bounds.
#' @param upper Upper interval bounds.
#' @param prediction Optional point predictions.
#' @param alpha Optional target miscoverage rate.
#' @return A `pharmax_conformal_calibration` object.
#' @export
px_calibrate_conformal <- function(truth,
                                   lower,
                                   upper,
                                   prediction = NULL,
                                   alpha = NULL) {
  if (length(truth) != length(lower) || length(truth) != length(upper)) {
    cli::cli_abort("{.arg truth}, {.arg lower}, and {.arg upper} must have the same length.")
  }
  if (!is.null(prediction) && length(prediction) != length(truth)) {
    cli::cli_abort("{.arg prediction} must match the length of {.arg truth}.")
  }

  covered <- truth >= lower & truth <= upper
  width <- upper - lower
  summary <- tibble::tibble(
    n = length(truth),
    empirical_coverage = mean(covered, na.rm = TRUE),
    target_coverage = if (is.null(alpha)) NA_real_ else 1 - alpha,
    mean_interval_width = mean(width, na.rm = TRUE),
    median_interval_width = stats::median(width, na.rm = TRUE)
  )

  calibration <- tibble::tibble(
    truth = truth,
    prediction = prediction %||% rep(NA_real_, length(truth)),
    lower = lower,
    upper = upper,
    covered = covered,
    interval_width = width
  )

  structure(
    list(summary = summary, calibration = calibration),
    class = "pharmax_conformal_calibration"
  )
}

#' Plot conformal calibration intervals
#'
#' @param x A `pharmax_conformal_calibration` object.
#' @param ... Unused.
#' @return A ggplot2 object.
#' @export
plot.pharmax_conformal_calibration <- function(x, ...) {
  calibration <- x$calibration
  calibration$row <- seq_len(nrow(calibration))
  ggplot2::ggplot(calibration, ggplot2::aes(x = .data$row, y = .data$truth)) +
    ggplot2::geom_linerange(
      ggplot2::aes(ymin = .data$lower, ymax = .data$upper, color = .data$covered)
    ) +
    ggplot2::geom_point(size = 1.8) +
    ggplot2::scale_color_manual(values = c("TRUE" = "#008f5d", "FALSE" = "#c43f5c")) +
    ggplot2::labs(
      title = "Conformal Calibration",
      x = "Observation",
      y = "Truth / interval",
      color = "Covered"
    ) +
    ggplot2::theme_minimal(base_size = 12)
}

#' @export
print.pharmax_conformal_calibration <- function(x, ...) {
  cat("pharmax conformal calibration\n\n")
  print(x$summary)
  invisible(x)
}
