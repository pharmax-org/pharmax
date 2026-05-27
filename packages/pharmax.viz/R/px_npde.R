# Purpose: NPDE-style distribution diagnostic panels
# Internal/exported: exported

#' NPDE diagnostic panel
#'
#' @param data Data frame containing an NPDE-like column.
#' @param npde NPDE column name.
#' @param time Optional time column.
#' @param prediction Optional prediction column.
#' @param mode Theme mode passed to [theme_pharmax()].
#' @return A patchwork plot object.
#' @export
px_npde <- function(data,
                    npde = "NPDE",
                    time = "TIME",
                    prediction = "PRED",
                    mode = "light") {
  require_columns(data, npde)
  base_theme <- theme_pharmax(mode = mode)

  p_hist <- ggplot2::ggplot(data, ggplot2::aes(x = .data[[npde]])) +
    ggplot2::geom_histogram(
      ggplot2::aes(y = ggplot2::after_stat(.data$density)),
      bins = 24,
      fill = px_colors(1),
      color = "white",
      alpha = 0.82
    ) +
    ggplot2::stat_function(fun = stats::dnorm, color = px_colors(2)[[2]], linewidth = 0.9) +
    ggplot2::labs(title = "NPDE Distribution", x = npde, y = "Density") +
    base_theme

  p_qq <- ggplot2::ggplot(data, ggplot2::aes(sample = .data[[npde]])) +
    ggplot2::stat_qq(alpha = 0.55, size = 1.5, color = px_colors(3)[[3]]) +
    ggplot2::stat_qq_line(color = "grey35") +
    ggplot2::labs(title = "NPDE QQ Plot", x = "Theoretical", y = "Sample") +
    base_theme

  p_time <- if (time %in% names(data)) {
    ggplot2::ggplot(data, ggplot2::aes(x = .data[[time]], y = .data[[npde]])) +
      ggplot2::geom_hline(yintercept = 0, color = "grey45") +
      ggplot2::geom_point(alpha = 0.45, size = 1.5, color = px_colors(4)[[4]]) +
      ggplot2::geom_smooth(method = "loess", se = FALSE, formula = y ~ x, linewidth = 0.8) +
      ggplot2::labs(title = paste(npde, "vs", time), x = time, y = npde) +
      base_theme
  } else {
    empty_panel(paste(npde, "vs", time), paste(time, "not available"), base_theme)
  }

  p_pred <- if (prediction %in% names(data)) {
    ggplot2::ggplot(data, ggplot2::aes(x = .data[[prediction]], y = .data[[npde]])) +
      ggplot2::geom_hline(yintercept = 0, color = "grey45") +
      ggplot2::geom_point(alpha = 0.45, size = 1.5, color = px_colors(5)[[5]]) +
      ggplot2::geom_smooth(method = "loess", se = FALSE, formula = y ~ x, linewidth = 0.8) +
      ggplot2::labs(title = paste(npde, "vs", prediction), x = prediction, y = npde) +
      base_theme
  } else {
    empty_panel(paste(npde, "vs", prediction), paste(prediction, "not available"), base_theme)
  }

  patchwork::wrap_plots(p_hist, p_qq, p_time, p_pred, ncol = 2) +
    patchwork::plot_annotation(title = "NPDE Diagnostics", theme = base_theme)
}
