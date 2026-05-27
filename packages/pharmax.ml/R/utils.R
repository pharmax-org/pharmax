# Purpose: Internal data validation and modeling utilities
# Internal/exported: internal

as_ml_data <- function(data, covariates = NULL, parameters = NULL) {
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame for this pharmax.ml release.")
  }

  if (is.null(parameters)) {
    parameters <- names(data)[grepl("^(ETA_|EBE_|PARAM_)", names(data))]
  }
  if (is.null(covariates)) {
    covariates <- names(data)[grepl("^(COV_)", names(data))]
    if (length(covariates) == 0) {
      covariates <- setdiff(names(data), c(parameters, "ID", "TIME", "DV", "EVID", "MDV"))
    }
  }

  if (length(parameters) == 0) {
    cli::cli_abort("No parameter columns found. Supply {.arg parameters}.")
  }
  if (length(covariates) == 0) {
    cli::cli_abort("No covariate columns found. Supply {.arg covariates}.")
  }

  missing <- setdiff(c(parameters, covariates), names(data))
  if (length(missing) > 0) {
    cli::cli_abort("Missing columns: {.field {missing}}")
  }

  list(data = data, parameters = parameters, covariates = covariates)
}

numeric_model_matrix <- function(data, covariates) {
  x <- stats::model.matrix(stats::as.formula(paste("~", paste(covariates, collapse = " + "))), data)
  x[, colnames(x) != "(Intercept)", drop = FALSE]
}

scale_importance <- function(x) {
  x <- abs(x)
  total <- sum(x, na.rm = TRUE)
  if (isTRUE(total == 0) || is.na(total)) {
    return(rep(0, length(x)))
  }
  x / total
}

new_covariate_result <- function(ranking, method, details = list()) {
  structure(
    list(
      ranking = ranking,
      method = method,
      details = details,
      context = details$context %||% list()
    ),
    class = "pharmax_covariate"
  )
}

ml_context <- function(method = NULL,
                       seed = NULL,
                       input_columns = character(),
                       parameter_columns = character(),
                       covariate_columns = character(),
                       limitations = character(),
                       warnings = character()) {
  list(
    package_version = tryCatch(
      as.character(utils::packageVersion("pharmax.ml")),
      error = function(e) NA_character_
    ),
    method = method,
    seed = seed,
    input_columns = input_columns,
    parameter_columns = parameter_columns,
    covariate_columns = covariate_columns,
    created_at = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
    warnings = warnings,
    limitations = limitations,
    human_review_required = TRUE
  )
}

#' @export
print.pharmax_covariate <- function(x, ...) {
  cat("pharmax covariate screening\n")
  cat("Method:", x$method, "\n\n")
  if (length(x$context) > 0) {
    parameters <- x$context$parameter_columns %||% x$context$parameters %||% character()
    covariates <- x$context$covariate_columns %||% x$context$covariates %||% character()
    cat("Parameters: ", paste(parameters, collapse = ", "), "\n", sep = "")
    cat("Covariates: ", paste(covariates, collapse = ", "), "\n", sep = "")
    if (length(x$context$warnings %||% character()) > 0) {
      cat("Warnings: ", paste(x$context$warnings, collapse = "; "), "\n", sep = "")
    }
  }
  print(x$ranking, n = min(20, nrow(x$ranking)))
  invisible(x)
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

scaled_numeric <- function(x) {
  as.numeric(scale(x)[, 1])
}
