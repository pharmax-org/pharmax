# Purpose: Lightweight visual predictive check plot
# Internal/exported: exported

#' Lightweight visual predictive check
#'
#' @param data Data frame with observed and simulated values.
#' @param time Time column.
#' @param observed Observed concentration column.
#' @param simulated Simulated concentration column.
#' @param bins Number of time bins. If `NULL`, exact time values are used.
#' @param probs Quantiles to show for observed and simulated values.
#' @param mode Theme mode passed to [theme_pharmax()].
#' @return A ggplot2 object.
#' @export
px_vpc <- function(data,
                   time = "TIME",
                   observed = "DV",
                   simulated = "SIM",
                   bins = NULL,
                   probs = c(0.05, 0.5, 0.95),
                   mode = "light") {
  require_columns(data, c(time, observed, simulated))
  if (length(probs) != 3 || any(probs <= 0) || any(probs >= 1)) {
    cli::cli_abort("{.arg probs} must contain three probabilities between 0 and 1.")
  }

  data$.px_bin <- make_time_bin(data[[time]], bins)
  data$.px_bin_mid <- stats::ave(
    data[[time]],
    data$.px_bin,
    FUN = function(x) stats::median(x, na.rm = TRUE)
  )

  observed_summary <- summarize_quantiles(data, ".px_bin", ".px_bin_mid", observed, probs)
  simulated_summary <- summarize_quantiles(data, ".px_bin", ".px_bin_mid", simulated, probs)

  ggplot2::ggplot() +
    ggplot2::geom_ribbon(
      data = simulated_summary,
      ggplot2::aes(x = .data$bin_mid, ymin = .data$lower, ymax = .data$upper),
      fill = px_colors(1),
      alpha = 0.18
    ) +
    ggplot2::geom_line(
      data = simulated_summary,
      ggplot2::aes(x = .data$bin_mid, y = .data$median),
      color = px_colors(1),
      linewidth = 0.9
    ) +
    ggplot2::geom_point(
      data = observed_summary,
      ggplot2::aes(x = .data$bin_mid, y = .data$median),
      color = px_colors(2)[[2]],
      size = 2
    ) +
    ggplot2::geom_errorbar(
      data = observed_summary,
      ggplot2::aes(x = .data$bin_mid, ymin = .data$lower, ymax = .data$upper),
      color = px_colors(2)[[2]],
      width = 0
    ) +
    ggplot2::labs(
      title = "Lightweight Visual Predictive Check",
      subtitle = "Ribbon: simulated interval; points/ranges: observed quantiles",
      x = time,
      y = observed
    ) +
    theme_pharmax(mode = mode)
}
