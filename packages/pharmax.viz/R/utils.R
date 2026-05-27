# Purpose: Internal utilities for validation and placeholder panels
# Internal/exported: internal

require_columns <- function(data, columns) {
  missing <- setdiff(columns, names(data))
  if (length(missing) > 0) {
    cli::cli_abort("Missing required column{?s}: {.field {missing}}")
  }
  invisible(data)
}

empty_panel <- function(title, subtitle, base_theme) {
  ggplot2::ggplot() +
    ggplot2::annotate("text", x = 0, y = 0, label = subtitle, color = "grey50") +
    ggplot2::labs(title = title, x = NULL, y = NULL) +
    ggplot2::xlim(-1, 1) +
    ggplot2::ylim(-1, 1) +
    base_theme
}

add_log10_if_positive <- function(plot, x, y) {
  if (all(x > 0, na.rm = TRUE) && all(y > 0, na.rm = TRUE)) {
    plot + ggplot2::scale_x_log10() + ggplot2::scale_y_log10()
  } else {
    plot
  }
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

first_available <- function(columns, candidates) {
  found <- candidates[candidates %in% columns]
  if (length(found) == 0) {
    return(NULL)
  }
  found[[1]]
}

make_time_bin <- function(time, bins = NULL) {
  if (is.null(bins)) {
    return(factor(time, levels = sort(unique(time)), ordered = TRUE))
  }
  if (!is.numeric(bins) || length(bins) != 1 || bins < 1) {
    cli::cli_abort("{.arg bins} must be a positive integer or {.code NULL}.")
  }
  base::cut(
    time,
    breaks = unique(stats::quantile(time, probs = seq(0, 1, length.out = bins + 1), na.rm = TRUE)),
    include.lowest = TRUE,
    ordered_result = TRUE
  )
}

summarize_quantiles <- function(data, bin_col, bin_mid_col, value_col, probs) {
  groups <- split(seq_len(nrow(data)), data[[bin_col]])
  rows <- lapply(groups, function(index) {
    values <- data[[value_col]][index]
    quantiles <- stats::quantile(values, probs = probs, na.rm = TRUE, names = FALSE)
    data.frame(
      bin = as.character(data[[bin_col]][index][[1]]),
      bin_mid = stats::median(data[[bin_mid_col]][index], na.rm = TRUE),
      lower = quantiles[[1]],
      median = quantiles[[2]],
      upper = quantiles[[3]]
    )
  })
  do.call(rbind, rows)
}
