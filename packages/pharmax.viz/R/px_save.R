# Purpose: Publication-ready plot export helper
# Internal/exported: exported

#' Save a pharmax plot
#'
#' @param plot A ggplot2 or patchwork plot.
#' @param filename Output filename.
#' @param width Width in inches.
#' @param height Height in inches.
#' @param dpi Resolution.
#' @param ... Additional arguments passed to [ggplot2::ggsave()].
#' @return The input filename, invisibly.
#' @export
px_save <- function(plot, filename, width = 8, height = 6, dpi = 300, ...) {
  ggplot2::ggsave(
    filename = filename,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi,
    bg = "white",
    ...
  )
  cli::cli_inform(c("v" = "Saved: {.file {filename}} ({width} x {height} in, {dpi} dpi)"))
  invisible(filename)
}
