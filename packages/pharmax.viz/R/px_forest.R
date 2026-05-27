# Purpose: Forest plots for parameter and covariate effects
# Internal/exported: exported

#' Forest plot for estimates and intervals
#'
#' @param data Data frame with estimate and interval columns.
#' @param term Term label column.
#' @param estimate Estimate column.
#' @param lower Lower interval column.
#' @param upper Upper interval column.
#' @param reference Reference line value.
#' @param mode Theme mode passed to [theme_pharmax()].
#' @return A ggplot2 object.
#' @export
px_forest <- function(data,
                      term = "term",
                      estimate = "estimate",
                      lower = "lower",
                      upper = "upper",
                      reference = 0,
                      mode = "light") {
  require_columns(data, c(term, estimate, lower, upper))

  plot_data <- data
  plot_data$.px_term <- stats::reorder(plot_data[[term]], plot_data[[estimate]])

  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = .data[[estimate]], y = .data$.px_term)
  ) +
    ggplot2::geom_vline(xintercept = reference, color = "grey45", linetype = "dashed") +
    ggplot2::geom_segment(
      ggplot2::aes(
        x = .data[[lower]],
        xend = .data[[upper]],
        y = .data$.px_term,
        yend = .data$.px_term
      ),
      color = px_colors(1),
      linewidth = 0.8
    ) +
    ggplot2::geom_point(size = 2.4, color = px_colors(2)[[2]]) +
    ggplot2::labs(title = "Parameter / Covariate Effect Forest Plot", x = estimate, y = NULL) +
    theme_pharmax(mode = mode)
}
