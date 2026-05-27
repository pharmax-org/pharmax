# Purpose: R-native ML covariate screening for pharmacometric parameters
# Internal/exported: exported

#' ML covariate screening
#'
#' Screens covariates against pharmacometric parameter columns using R-native
#' methods.
#'
#' @param data Data frame containing parameter and covariate columns.
#' @param covariates Covariate column names. Auto-detects `COV_` columns when `NULL`.
#' @param parameters Parameter column names. Auto-detects `ETA_`, `EBE_`, or `PARAM_`.
#' @param method One of `"auto"`, `"rf"`, `"elastic_net"`, `"lasso"`, `"aalasso"`,
#'   or `"cor"`.
#' @param n_top Number of top covariates per parameter.
#' @param seed Random seed.
#' @return A `pharmax_covariate` object.
#' @export
px_covariate <- function(data,
                         covariates = NULL,
                         parameters = NULL,
                         method = c(
                           "auto", "rf", "elastic_net", "lasso", "aalasso", "cor"
                         ),
                         n_top = 10L,
                         seed = 42L) {
  method <- match.arg(method)
  spec <- as_ml_data(data, covariates, parameters)

  methods <- if (identical(method, "auto")) {
    c("rf", "elastic_net", "lasso", "aalasso", "cor")
  } else {
    method
  }

  rankings <- purrr::map_dfr(
    methods,
    function(one_method) {
      screen_one_method(spec$data, spec$parameters, spec$covariates, one_method, seed)
    }
  )

  if (identical(method, "auto")) {
    ranking <- rankings |>
      dplyr::group_by(.data$parameter, .data$covariate) |>
      dplyr::summarise(
        importance = mean(.data$importance, na.rm = TRUE),
        methods = paste(sort(unique(.data$method)), collapse = ", "),
        method_agreement = dplyr::n_distinct(.data$method),
        .groups = "drop"
      ) |>
      dplyr::arrange(.data$parameter, dplyr::desc(.data$importance)) |>
      dplyr::group_by(.data$parameter) |>
      dplyr::mutate(rank = dplyr::row_number()) |>
      dplyr::filter(.data$rank <= n_top) |>
      dplyr::ungroup()
  } else {
    ranking <- rankings |>
      dplyr::arrange(.data$parameter, dplyr::desc(.data$importance)) |>
      dplyr::group_by(.data$parameter) |>
      dplyr::mutate(rank = dplyr::row_number()) |>
      dplyr::filter(.data$rank <= n_top) |>
      dplyr::ungroup()
  }

  ambiguity <- detect_covariate_ambiguity(spec$data, spec$covariates, ranking)

  context <- ml_context(
    seed = seed,
    method = method,
    input_columns = names(spec$data),
    parameter_columns = spec$parameters,
    covariate_columns = spec$covariates,
    warnings = ambiguity$warnings,
    limitations = c(
      "Covariate screening is hypothesis generation, not automatic model selection.",
      "Correlated covariates and weak signals require pharmacometric review."
    )
  )
  context$parameters <- spec$parameters
  context$covariates <- spec$covariates

  new_covariate_result(
    ranking = ranking,
    method = method,
    details = list(all_rankings = rankings, context = context, ambiguity = ambiguity)
  )
}

screen_one_method <- function(data, parameters, covariates, method, seed) {
  purrr::map_dfr(parameters, function(parameter) {
    y <- data[[parameter]]
    x <- numeric_model_matrix(data, covariates)
    complete <- stats::complete.cases(cbind(y, x))
    y <- y[complete]
    x <- x[complete, , drop = FALSE]

    importance <- switch(
      method,
      rf = rf_importance(x, y, seed),
      elastic_net = glmnet_importance(x, y, alpha = 0.5, seed = seed),
      lasso = glmnet_importance(x, y, alpha = 1, seed = seed),
      aalasso = adaptive_lasso_importance(x, y, seed = seed),
      cor = cor_importance(x, y)
    )

    tibble::tibble(
      parameter = parameter,
      covariate = names(importance),
      importance = as.numeric(importance),
      method = method
    )
  })
}

rf_importance <- function(x, y, seed) {
  set.seed(seed)
  fit <- ranger::ranger(
    x = as.data.frame(x),
    y = y,
    importance = "permutation",
    num.trees = 300,
    seed = seed
  )
  scale_importance(fit$variable.importance) |> stats::setNames(names(fit$variable.importance))
}

glmnet_importance <- function(x, y, alpha, seed) {
  set.seed(seed)
  fit <- glmnet::cv.glmnet(x = x, y = y, alpha = alpha, family = "gaussian")
  coefs <- as.matrix(stats::coef(fit, s = "lambda.min"))
  coefs <- coefs[rownames(coefs) != "(Intercept)", , drop = FALSE]
  scale_importance(coefs[, 1]) |> stats::setNames(rownames(coefs))
}

adaptive_lasso_importance <- function(x, y, seed) {
  ridge <- glmnet_importance(x, y, alpha = 0, seed = seed)
  weights <- 1 / pmax(abs(ridge), .Machine$double.eps)
  x_weighted <- sweep(x, 2, weights, "/")
  raw <- glmnet_importance(x_weighted, y, alpha = 1, seed = seed)
  scale_importance(raw / weights) |> stats::setNames(names(raw))
}

cor_importance <- function(x, y) {
  vals <- apply(x, 2, function(col) {
    stats::cor(col, y, use = "pairwise.complete.obs")
  })
  scale_importance(vals) |> stats::setNames(names(vals))
}

detect_covariate_ambiguity <- function(data, covariates, ranking) {
  warnings <- character()
  numeric_covariates <- covariates[vapply(data[covariates], is.numeric, logical(1))]
  if (length(numeric_covariates) >= 2) {
    cors <- stats::cor(data[numeric_covariates], use = "pairwise.complete.obs")
    cors[lower.tri(cors, diag = TRUE)] <- NA_real_
    high <- which(abs(cors) > 0.7, arr.ind = TRUE)
    if (nrow(high) > 0) {
      warnings <- c(warnings, "Correlated covariates detected; rankings may be ambiguous.")
    }
  }
  if (nrow(ranking) > 0 && max(ranking$importance, na.rm = TRUE) < 0.2) {
    warnings <- c(warnings, "No strong covariate signal detected.")
  }
  list(warnings = unique(warnings), correlated_or_weak_signal = length(warnings) > 0)
}

#' Plot covariate screening results
#'
#' @param x A `pharmax_covariate` object.
#' @param ... Unused.
#' @return A ggplot2 object.
#' @export
plot.pharmax_covariate <- function(x, ...) {
  ggplot2::ggplot(
    x$ranking,
    ggplot2::aes(x = stats::reorder(.data$covariate, .data$importance), y = .data$importance)
  ) +
    ggplot2::geom_col(fill = "#2563EB") +
    ggplot2::coord_flip() +
    ggplot2::facet_wrap(ggplot2::vars(.data$parameter), scales = "free_y") +
    ggplot2::labs(x = "Covariate", y = "Importance", title = "ML Covariate Screening")
}
