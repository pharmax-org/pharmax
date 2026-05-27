# Purpose: Package startup message for public package context

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "pharmax ", utils::packageVersion(pkgname),
    " | public package coordinator | use px_public_packages()"
  )
}
