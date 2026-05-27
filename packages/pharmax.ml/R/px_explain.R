# Purpose: Lightweight model explainability helpers
# Internal/exported: exported

#' Explain a fitted model with permutation importance
#'
#' @param model Fitted model with a `predict()` method.
#' @param data Data frame of predictors.
#' @param truth Observed outcome.
#' @param metric Loss metric, currently `"rmse"`.
#' @param method Explanation method: `"permutation"`, `"pdp"`, or `"ice"`.
#' @param seed Random seed.
#' @return Tibble of feature importance values.
#' @export
px_explain <- function(model,
                       data,
                       truth = NULL,
                       metric = c("rmse"),
                       method = c("permutation", "pdp", "ice"),
                       seed = 42L) {
  metric <- match.arg(metric)
  method <- match.arg(method)
  set.seed(seed)

  if (method %in% c("pdp", "ice")) {
    return(explain_effect_grid(model, data, method))
  }

  if (is.null(truth)) {
    cli::cli_abort("{.arg truth} is required for permutation explanations.")
  }

  base_pred <- stats::predict(model, data = data)$predictions %||% stats::predict(model, newdata = data)
  base_loss <- loss_value(truth, base_pred, metric)

  purrr::map_dfr(names(data), function(feature) {
    shuffled <- data
    shuffled[[feature]] <- sample(shuffled[[feature]])
    pred <- tryCatch(
      stats::predict(model, data = shuffled)$predictions,
      error = function(e) stats::predict(model, newdata = shuffled)
    )
    tibble::tibble(
      feature = feature,
      importance = loss_value(truth, pred, metric) - base_loss,
      metric = metric,
      method = method
    )
  }) |>
    dplyr::arrange(dplyr::desc(.data$importance))
}

explain_effect_grid <- function(model, data, method) {
  purrr::map_dfr(names(data), function(feature) {
    values <- stats::quantile(data[[feature]], probs = c(0.1, 0.5, 0.9), na.rm = TRUE)
    purrr::map_dfr(values, function(value) {
      modified <- data
      modified[[feature]] <- value
      pred <- predict_numeric(model, modified)
      tibble::tibble(
        feature = feature,
        value = as.numeric(value),
        mean_prediction = mean(pred, na.rm = TRUE),
        method = method
      )
    })
  })
}

loss_value <- function(truth, prediction, metric) {
  switch(
    metric,
    rmse = sqrt(mean((truth - prediction)^2, na.rm = TRUE))
  )
}
