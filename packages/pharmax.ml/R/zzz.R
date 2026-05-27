# Purpose: Package startup messaging
# Internal/exported: internal

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "pharmax.ml ", utils::packageVersion(pkgname),
    " | R-native public proof slice"
  )
}
