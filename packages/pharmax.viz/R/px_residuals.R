# Purpose: Residual diagnostic panels for pharmacometric model review
# Internal/exported: exported

#' Residual diagnostic panel
#'
#' Creates residual-vs-time, residual-vs-prediction, histogram, and QQ panels.
#'
#' @param data Data frame containing residual columns.
#' @param residual Residual column. Auto-detects `CWRES`, `IWRES`, then `RES`.
#' @param time Time column used for residual-vs-time when available.
#' @param prediction Prediction column used for residual-vs-prediction when available.
#' @param mode Theme mode passed to [theme_pharmax()].
#' @return A patchwork plot object.
#' @export
px_residuals <- function(data,
                         residual = NULL,
                         time = "TIME",
                         prediction = "PRED",
                         mode = "light") {
  residual <- residual %||% first_available(names(data), c("CWRES", "IWRES", "RES"))
  if (is.null(residual)) {
    cli::cli_abort("No residual column found. Provide {.arg residual} or include CWRES, IWRES, or RES.")
  }
  require_columns(data, residual)

  base_theme <- theme_pharmax(mode = mode)
  residual_label <- residual

  p_time <- if (time %in% names(data)) {
    ggplot2::ggplot(data, ggplot2::aes(x = .data[[time]], y = .data[[residual]])) +
      ggplot2::geom_hline(yintercept = 0, color = "grey45") +
      ggplot2::geom_hline(yintercept = c(-2, 2), linetype = "dashed", color = "grey65") +
      ggplot2::geom_point(alpha = 0.45, size = 1.5, color = px_colors(1)) +
      ggplot2::geom_smooth(method = "loess", se = FALSE, formula = y ~ x, linewidth = 0.8) +
      ggplot2::labs(title = paste(residual_label, "vs", time), x = time, y = residual_label) +
      base_theme
  } else {
    empty_panel(paste(residual_label, "vs", time), paste(time, "not available"), base_theme)
  }

  p_pred <- if (prediction %in% names(data)) {
    ggplot2::ggplot(data, ggplot2::aes(x = .data[[prediction]], y = .data[[residual]])) +
      ggplot2::geom_hline(yintercept = 0, color = "grey45") +
      ggplot2::geom_hline(yintercept = c(-2, 2), linetype = "dashed", color = "grey65") +
      ggplot2::geom_point(alpha = 0.45, size = 1.5, color = px_colors(2)[[2]]) +
      ggplot2::geom_smooth(method = "loess", se = FALSE, formula = y ~ x, linewidth = 0.8) +
      ggplot2::labs(title = paste(residual_label, "vs", prediction), x = prediction, y = residual_label) +
      base_theme
  } else {
    empty_panel(
      paste(residual_label, "vs", prediction),
      paste(prediction, "not available"),
      base_theme
    )
  }

  p_hist <- ggplot2::ggplot(data, ggplot2::aes(x = .data[[residual]])) +
    ggplot2::geom_histogram(bins = 24, fill = px_colors(3)[[3]], color = "white", alpha = 0.85) +
    ggplot2::geom_vline(xintercept = 0, color = "grey35") +
    ggplot2::labs(title = paste(residual_label, "Distribution"), x = residual_label, y = "Count") +
    base_theme

  p_qq <- ggplot2::ggplot(data, ggplot2::aes(sample = .data[[residual]])) +
    ggplot2::stat_qq(alpha = 0.55, size = 1.5, color = px_colors(4)[[4]]) +
    ggplot2::stat_qq_line(color = "grey35") +
    ggplot2::labs(title = paste(residual_label, "QQ Plot"), x = "Theoretical", y = "Sample") +
    base_theme

  patchwork::wrap_plots(p_time, p_pred, p_hist, p_qq, ncol = 2) +
    patchwork::plot_annotation(title = "Residual Diagnostics", theme = base_theme)
}
