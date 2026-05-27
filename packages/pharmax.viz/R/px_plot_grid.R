# Purpose: Compose pharmax plots with consistent annotation
# Internal/exported: exported

#' Compose pharmax plots
#'
#' @param ... ggplot2 or patchwork plots, or a single list of plots.
#' @param ncol Number of columns.
#' @param title Optional grid title.
#' @param subtitle Optional grid subtitle.
#' @param caption Optional grid caption.
#' @param mode Theme mode passed to [theme_pharmax()].
#' @return A patchwork plot object.
#' @export
px_plot_grid <- function(...,
                         ncol = 2,
                         title = NULL,
                         subtitle = NULL,
                         caption = NULL,
                         mode = "light") {
  plots <- list(...)
  if (length(plots) == 1 && is.list(plots[[1]]) && !inherits(plots[[1]], "gg")) {
    plots <- plots[[1]]
  }
  if (length(plots) == 0) {
    cli::cli_abort("Provide at least one plot.")
  }

  patchwork::wrap_plots(plots, ncol = ncol) +
    patchwork::plot_annotation(
      title = title,
      subtitle = subtitle,
      caption = caption,
      theme = theme_pharmax(mode = mode)
    )
}
