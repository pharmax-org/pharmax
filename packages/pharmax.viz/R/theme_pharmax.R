# Purpose: Shared ggplot2 theme and palette helpers for Pharmax figures
# Internal/exported: exported

#' The pharmax ggplot2 theme
#'
#' A clean, publication-ready theme for pharmacometric graphics.
#'
#' @param base_size Base font size.
#' @param base_family Base font family.
#' @param mode Theme mode, either `"light"` or `"dark"`.
#' @return A ggplot2 theme object.
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   theme_pharmax()
theme_pharmax <- function(base_size = 12, base_family = "", mode = c("light", "dark")) {
  mode <- match.arg(mode)

  colors <- if (identical(mode, "light")) {
    list(bg = "#FFFFFF", text = "#1A1A2E", grid = "#E8E8E8", panel = "#FAFAFA", subtle = "#666666")
  } else {
    list(bg = "#1A1A2E", text = "#E8E8E8", grid = "#2D2D44", panel = "#16162A", subtle = "#999999")
  }

  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = colors$bg, color = NA),
      panel.background = ggplot2::element_rect(fill = colors$panel, color = NA),
      panel.grid.major = ggplot2::element_line(color = colors$grid, linewidth = 0.3),
      panel.grid.minor = ggplot2::element_blank(),
      text = ggplot2::element_text(color = colors$text),
      plot.title = ggplot2::element_text(
        size = base_size * 1.2,
        face = "bold",
        margin = ggplot2::margin(b = 8)
      ),
      plot.subtitle = ggplot2::element_text(
        size = base_size * 0.9,
        color = colors$subtle,
        margin = ggplot2::margin(b = 12)
      ),
      axis.title = ggplot2::element_text(size = base_size * 0.95),
      axis.text = ggplot2::element_text(size = base_size * 0.85),
      legend.position = "bottom",
      legend.background = ggplot2::element_rect(fill = "transparent", color = NA),
      legend.key = ggplot2::element_rect(fill = "transparent", color = NA),
      strip.background = ggplot2::element_rect(fill = colors$grid, color = NA),
      strip.text = ggplot2::element_text(face = "bold", size = base_size * 0.9),
      plot.margin = ggplot2::margin(15, 15, 15, 15)
    )
}

#' pharmax color palette
#'
#' @param n Number of colors.
#' @return Character vector of hex colors.
#' @export
px_colors <- function(n = 8) {
  palette <- c(
    "#2563EB",
    "#DC2626",
    "#16A34A",
    "#9333EA",
    "#EA580C",
    "#0891B2",
    "#CA8A04",
    "#64748B"
  )

  if (n <= length(palette)) {
    return(palette[seq_len(n)])
  }

  grDevices::colorRampPalette(palette)(n)
}

#' pharmax color scale for ggplot2
#'
#' @param ... Arguments passed to [ggplot2::discrete_scale()].
#' @export
scale_color_pharmax <- function(...) {
  ggplot2::discrete_scale("colour", palette = function(n) px_colors(n), ...)
}

#' @rdname scale_color_pharmax
#' @export
scale_fill_pharmax <- function(...) {
  ggplot2::discrete_scale("fill", palette = function(n) px_colors(n), ...)
}
