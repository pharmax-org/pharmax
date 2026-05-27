# Purpose: Individual concentration-time profile plots
# Internal/exported: exported

#' Individual PK concentration-time profiles
#'
#' @param data Data frame with `ID`, `TIME`, and `DV` columns.
#' @param group Optional grouping variable for color.
#' @param log_y Use a log10 y-axis.
#' @param facet_by Optional column to facet by.
#' @param highlight_ids Optional vector of subject IDs to highlight.
#' @param mode Theme mode passed to [theme_pharmax()].
#' @return A ggplot2 object.
#' @export
px_spaghetti <- function(data,
                         group = NULL,
                         log_y = FALSE,
                         facet_by = NULL,
                         highlight_ids = NULL,
                         mode = "light") {
  require_columns(data, c("ID", "TIME", "DV"))

  if ("EVID" %in% names(data)) {
    data <- data[data$EVID == 0, , drop = FALSE]
  }

  p <- ggplot2::ggplot(
    data,
    ggplot2::aes(x = .data$TIME, y = .data$DV, group = factor(.data$ID))
  )

  if (!is.null(highlight_ids)) {
    background <- data[!data$ID %in% highlight_ids, , drop = FALSE]
    foreground <- data[data$ID %in% highlight_ids, , drop = FALSE]
    p <- p +
      ggplot2::geom_line(data = background, alpha = 0.15, color = "grey60") +
      ggplot2::geom_point(data = background, alpha = 0.15, size = 1, color = "grey60") +
      ggplot2::geom_line(
        data = foreground,
        ggplot2::aes(color = factor(.data$ID)),
        alpha = 0.8,
        linewidth = 0.8
      ) +
      ggplot2::geom_point(
        data = foreground,
        ggplot2::aes(color = factor(.data$ID)),
        alpha = 0.8,
        size = 2
      ) +
      ggplot2::labs(color = "Subject ID")
  } else if (!is.null(group)) {
    if (!group %in% names(data)) {
      cli::cli_abort("Grouping column {.field {group}} was not found in {.arg data}.")
    }
    p <- p +
      ggplot2::geom_line(ggplot2::aes(color = factor(.data[[group]])), alpha = 0.5) +
      ggplot2::geom_point(ggplot2::aes(color = factor(.data[[group]])), alpha = 0.6, size = 1.5) +
      scale_color_pharmax() +
      ggplot2::labs(color = group)
  } else {
    p <- p +
      ggplot2::geom_line(alpha = 0.3, color = px_colors(1)) +
      ggplot2::geom_point(alpha = 0.5, size = 1.5, color = px_colors(1))
  }

  p <- p +
    ggplot2::labs(
      title = "Individual Concentration-Time Profiles",
      x = "Time",
      y = "Concentration"
    ) +
    theme_pharmax(mode = mode)

  if (isTRUE(log_y)) {
    p <- p + ggplot2::scale_y_log10()
  }

  if (!is.null(facet_by)) {
    if (!facet_by %in% names(data)) {
      cli::cli_abort("Facet column {.field {facet_by}} was not found in {.arg data}.")
    }
    p <- p + ggplot2::facet_wrap(ggplot2::vars(.data[[facet_by]]))
  }

  p
}
