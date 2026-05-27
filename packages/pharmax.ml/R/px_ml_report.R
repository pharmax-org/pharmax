# Purpose: Structured ML decision-support summary
# Internal/exported: exported

#' Create an ML decision-support report object
#'
#' @param screen A `pharmax_covariate` object.
#' @param quality Optional `pharmax_data_quality` object.
#' @param calibration Optional `pharmax_conformal_calibration` object.
#' @param benchmark Optional `pharmax_covariate_benchmark` object.
#' @param context Optional named list describing the context of use.
#' @return A `pharmax_ml_report` object.
#' @export
px_ml_report <- function(screen,
                         quality = NULL,
                         calibration = NULL,
                         benchmark = NULL,
                         context = list()) {
  if (!inherits(screen, "pharmax_covariate")) {
    cli::cli_abort("{.arg screen} must be a pharmax_covariate object.")
  }

  top_signals <- screen$ranking |>
    dplyr::group_by(.data$parameter) |>
    dplyr::slice_min(.data$rank, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()

  data_quality <- if (inherits(quality, "pharmax_data_quality")) {
    list(
      missing = quality$missing,
      outliers = quality$outliers
    )
  } else {
    NULL
  }

  uncertainty <- if (inherits(calibration, "pharmax_conformal_calibration")) {
    calibration$summary
  } else {
    NULL
  }

  evidence <- list(
    top_signals = top_signals,
    data_quality = data_quality,
    uncertainty = uncertainty,
    benchmark = if (inherits(benchmark, "pharmax_covariate_benchmark")) benchmark$summary else NULL,
    limitations = c(
      "Exploratory decision support only.",
      "Synthetic/public examples do not establish clinical validity.",
      "Human pharmacometric review is required before acting on results."
    ),
    human_oversight = "Outputs are intended for human-reviewed model-informed workflow support.",
    context = utils::modifyList(screen$context %||% list(), context)
  )

  structure(evidence, class = "pharmax_ml_report")
}

#' @export
print.pharmax_ml_report <- function(x, ...) {
  cat("pharmax ML decision-support report\n\n")
  cat("Top signals:\n")
  print(x$top_signals, n = min(10, nrow(x$top_signals)))
  cat("\nLimitations:\n")
  cat(paste("*", x$limitations), sep = "\n")
  cat("\n\nHuman oversight:", x$human_oversight, "\n")
  invisible(x)
}
