# Purpose: Public package registry and startup status helpers

pharmax_public_registry <- function() {
  data.frame(
    package = c("pharmax", "pharmax.viz", "pharmax.ml"),
    role = c(
      "public package coordinator",
      "pharmacometric visualization",
      "R-native exploratory ML helpers"
    ),
    public_status = c("coordinator", "alpha-mature", "beta"),
    stringsAsFactors = FALSE
  )
}

#' List public pharmax packages
#'
#' @return A data frame with package names, roles, and public status labels.
#' @export
px_public_packages <- function() {
  pharmax_public_registry()
}

#' Summarize the current public pharmax surface
#'
#' @return A named list with package counts and public-scope limitations.
#' @export
px_public_status <- function() {
  packages <- pharmax_public_registry()
  list(
    version = as.character(utils::packageVersion("pharmax")),
    packages = packages,
    package_count = nrow(packages),
    ready_for = "public proof-of-implementation review",
    limitation = paste(
      "Exploratory decision support only;",
      "not validated for regulatory submission or clinical decision support."
    )
  )
}
