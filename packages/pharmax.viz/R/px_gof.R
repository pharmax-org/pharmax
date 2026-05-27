# Purpose: Goodness-of-fit diagnostic panels
# Internal/exported: exported

#' Goodness-of-fit diagnostic panel
#'
#' Creates a four-panel diagnostic plot: DV vs PRED, DV vs IPRED, CWRES vs TIME,
#' and CWRES vs PRED.
#'
#' @param data Data frame with at least `DV` and `PRED` columns.
#' @param log_scale Use log10 axes for observed-vs-predicted panels.
#' @param mode Theme mode passed to [theme_pharmax()].
#' @return A patchwork plot object.
#' @export
px_gof <- function(data, log_scale = TRUE, mode = "light") {
  require_columns(data, c("DV", "PRED"))

  if ("EVID" %in% names(data)) {
    data <- data[data$EVID == 0, , drop = FALSE]
  }

  base_theme <- theme_pharmax(mode = mode)

  p1 <- ggplot2::ggplot(data, ggplot2::aes(x = .data$PRED, y = .data$DV)) +
    ggplot2::geom_point(alpha = 0.5, size = 1.5, color = px_colors(1)) +
    ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey40") +
    ggplot2::labs(title = "DV vs PRED", x = "Population Predicted", y = "Observed") +
    base_theme

  p2 <- if ("IPRED" %in% names(data)) {
    ggplot2::ggplot(data, ggplot2::aes(x = .data$IPRED, y = .data$DV)) +
      ggplot2::geom_point(alpha = 0.5, size = 1.5, color = px_colors(2)[[2]]) +
      ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey40") +
      ggplot2::labs(title = "DV vs IPRED", x = "Individual Predicted", y = "Observed") +
      base_theme
  } else {
    empty_panel("DV vs IPRED", "IPRED not available", base_theme)
  }

  p3 <- if (all(c("CWRES", "TIME") %in% names(data))) {
    ggplot2::ggplot(data, ggplot2::aes(x = .data$TIME, y = .data$CWRES)) +
      ggplot2::geom_point(alpha = 0.4, size = 1.5, color = px_colors(3)[[3]]) +
      ggplot2::geom_hline(yintercept = 0, color = "grey40") +
      ggplot2::geom_hline(yintercept = c(-2, 2), linetype = "dashed", color = "grey60") +
      ggplot2::geom_smooth(method = "loess", se = FALSE, formula = y ~ x, linewidth = 0.8) +
      ggplot2::labs(title = "CWRES vs Time", x = "Time", y = "CWRES") +
      base_theme
  } else {
    empty_panel("CWRES vs Time", "CWRES/TIME not available", base_theme)
  }

  p4 <- if ("CWRES" %in% names(data)) {
    ggplot2::ggplot(data, ggplot2::aes(x = .data$PRED, y = .data$CWRES)) +
      ggplot2::geom_point(alpha = 0.4, size = 1.5, color = px_colors(4)[[4]]) +
      ggplot2::geom_hline(yintercept = 0, color = "grey40") +
      ggplot2::geom_hline(yintercept = c(-2, 2), linetype = "dashed", color = "grey60") +
      ggplot2::geom_smooth(method = "loess", se = FALSE, formula = y ~ x, linewidth = 0.8) +
      ggplot2::labs(title = "CWRES vs PRED", x = "Population Predicted", y = "CWRES") +
      base_theme
  } else {
    empty_panel("CWRES vs PRED", "CWRES not available", base_theme)
  }

  if (isTRUE(log_scale)) {
    p1 <- add_log10_if_positive(p1, data$PRED, data$DV)
    if ("IPRED" %in% names(data)) {
      p2 <- add_log10_if_positive(p2, data$IPRED, data$DV)
    }
  }

  patchwork::wrap_plots(p1, p2, p3, p4, ncol = 2) +
    patchwork::plot_annotation(title = "Goodness-of-Fit Diagnostics", theme = base_theme)
}
