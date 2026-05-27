# Purpose: Simple ensemble utilities for ML predictions
# Internal/exported: exported

#' Ensemble predictions
#'
#' @param ... Numeric prediction vectors or a data frame of predictions.
#' @param weights Optional numeric weights.
#' @param newdata Optional data used when inputs are fitted models.
#' @param method Ensemble method: `"average"`, `"weighted"`, or `"stacking"`.
#' @return Numeric vector of ensemble predictions with a `pharmax_ensemble` class.
#' @export
px_ensemble <- function(...,
                        weights = NULL,
                        newdata = NULL,
                        method = c("average", "weighted", "stacking")) {
  method <- match.arg(method)
  inputs <- list(...)
  if (all(vapply(inputs, is.atomic, logical(1))) && !all(vapply(inputs, is.numeric, logical(1)))) {
    cli::cli_abort("All predictions must be numeric.")
  }
  if (all(vapply(inputs, is.numeric, logical(1)))) {
    preds <- do.call(cbind, inputs)
  } else if (length(inputs) == 1 && is.data.frame(inputs[[1]])) {
    preds <- as.matrix(inputs[[1]])
  } else {
    if (is.null(newdata)) {
      cli::cli_abort("{.arg newdata} is required when ensembling fitted models.")
    }
    preds <- do.call(cbind, lapply(inputs, predict_numeric, newdata = newdata))
  }

  if (!is.numeric(preds)) {
    cli::cli_abort("All predictions must be numeric.")
  }

  if (is.null(weights)) {
    weights <- rep(1 / ncol(preds), ncol(preds))
  }
  if (length(weights) != ncol(preds)) {
    cli::cli_abort("{.arg weights} must match the number of prediction columns.")
  }

  as.numeric(preds %*% (weights / sum(weights)))
}

predict_numeric <- function(model, newdata) {
  pred <- tryCatch(
    stats::predict(model, data = newdata)$predictions,
    error = function(e) stats::predict(model, newdata = newdata)
  )
  as.numeric(pred)
}
