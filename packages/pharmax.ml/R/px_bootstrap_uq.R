# Purpose: Bootstrap uncertainty summaries
# Internal/exported: exported

#' Bootstrap prediction uncertainty
#'
#' @param truth Observed outcomes.
#' @param prediction Point predictions.
#' @param n_boot Number of bootstrap replicates.
#' @param alpha Miscoverage rate.
#' @param seed Random seed.
#' @return A `pharmax_bootstrap_uq` object.
#' @export
px_bootstrap_uq <- function(truth, prediction, n_boot = 200L, alpha = 0.1, seed = 42L) {
  if (length(truth) != length(prediction)) {
    cli::cli_abort("{.arg truth} and {.arg prediction} must have the same length.")
  }
  if (alpha <= 0 || alpha >= 1) {
    cli::cli_abort("{.arg alpha} must be between 0 and 1.")
  }
  set.seed(seed)
  residual <- truth - prediction
  boot_rmse <- replicate(n_boot, {
    idx <- sample(seq_along(residual), replace = TRUE)
    sqrt(mean(residual[idx]^2, na.rm = TRUE))
  })
  structure(
    list(
      summary = tibble::tibble(
        n = length(truth),
        n_boot = n_boot,
        rmse = sqrt(mean(residual^2, na.rm = TRUE)),
        lower = stats::quantile(boot_rmse, alpha / 2, names = FALSE),
        upper = stats::quantile(boot_rmse, 1 - alpha / 2, names = FALSE)
      ),
      bootstrap = tibble::tibble(rmse = boot_rmse),
      context = ml_context(
        method = "bootstrap_uq",
        seed = seed,
        limitations = "Bootstrap uncertainty summarizes resampling variability, not formal validation."
      )
    ),
    class = "pharmax_bootstrap_uq"
  )
}

#' @export
print.pharmax_bootstrap_uq <- function(x, ...) {
  cat("pharmax bootstrap uncertainty\n\n")
  print(x$summary)
  invisible(x)
}
