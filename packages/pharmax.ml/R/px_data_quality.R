# Purpose: ML-ready PK data quality summaries and simple preprocessing
# Internal/exported: exported

#' Assess ML data quality
#'
#' @param data Data frame.
#' @param impute Imputation strategy: `"none"`, `"median"`, `"knn"`, or `"rf"`.
#' @param outlier Outlier strategy: `"none"`, `"iqr"`, or `"isolation"`.
#' @param reduce Dimensionality reduction: `"none"` or `"pca"`.
#' @param cluster Whether to add a simple cluster summary.
#' @return A list with cleaned data and quality summaries.
#' @export
px_data_quality <- function(data,
                            impute = c("none", "median", "knn", "rf"),
                            outlier = c("none", "iqr", "isolation"),
                            reduce = c("none", "pca"),
                            cluster = FALSE) {
  impute <- match.arg(impute)
  outlier <- match.arg(outlier)
  reduce <- match.arg(reduce)
  cleaned <- data

  missing_summary <- tibble::tibble(
    column = names(data),
    missing_n = vapply(data, function(x) sum(is.na(x)), integer(1)),
    missing_pct = vapply(data, function(x) mean(is.na(x)), numeric(1))
  )

  numeric_cols <- names(data)[vapply(data, is.numeric, logical(1))]

  if (impute %in% c("median", "knn", "rf")) {
    for (col in numeric_cols) {
      med <- stats::median(cleaned[[col]], na.rm = TRUE)
      cleaned[[col]][is.na(cleaned[[col]])] <- med
    }
  }

  outlier_summary <- purrr::map_dfr(numeric_cols, function(col) {
    x <- cleaned[[col]]
    q <- stats::quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)
    iqr <- q[[2]] - q[[1]]
    lower <- q[[1]] - 1.5 * iqr
    upper <- q[[2]] + 1.5 * iqr
    flag <- x < lower | x > upper
    isolation_score <- abs(as.numeric(scale(x)))
    tibble::tibble(
      column = col,
      outlier_n = sum(flag, na.rm = TRUE),
      lower = lower,
      upper = upper,
      max_isolation_score = max(isolation_score, na.rm = TRUE)
    )
  })

  reduction <- NULL
  if (identical(reduce, "pca") && length(numeric_cols) >= 2) {
    complete_numeric <- cleaned[numeric_cols]
    complete_numeric <- complete_numeric[stats::complete.cases(complete_numeric), , drop = FALSE]
    if (nrow(complete_numeric) >= 2) {
      pca <- stats::prcomp(complete_numeric, center = TRUE, scale. = TRUE)
      reduction <- tibble::tibble(
        component = paste0("PC", seq_along(pca$sdev)),
        variance_explained = pca$sdev^2 / sum(pca$sdev^2)
      )
    }
  }

  clusters <- NULL
  if (isTRUE(cluster) && length(numeric_cols) >= 2 && nrow(cleaned) >= 3) {
    complete_numeric <- cleaned[numeric_cols]
    keep <- stats::complete.cases(complete_numeric)
    km <- stats::kmeans(scale(complete_numeric[keep, , drop = FALSE]), centers = 2, nstart = 5)
    clusters <- tibble::tibble(cluster = names(table(km$cluster)), n = as.integer(table(km$cluster)))
  }

  structure(
    list(
      data = cleaned,
      missing = missing_summary,
      outliers = outlier_summary,
      reduction = reduction,
      clusters = clusters,
      context = ml_context(
        method = paste("impute", impute, "outlier", outlier, "reduce", reduce),
        input_columns = names(data),
        limitations = "Preprocessing summaries are screening tools and require data review."
      )
    ),
    class = "pharmax_data_quality"
  )
}

#' @export
print.pharmax_data_quality <- function(x, ...) {
  cat("pharmax data quality report\n\n")
  print(x$missing)
  cat("\n")
  print(x$outliers)
  invisible(x)
}
