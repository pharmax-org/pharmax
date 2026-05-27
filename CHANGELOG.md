# Changelog

All notable changes to the public Pharmax repository will be documented here.

## 0.3.0-public — 2026-05-27

- Reset the public repository to the current three-package proof slice:
  `pharmax`, `pharmax.viz`, and `pharmax.ml`.
- Replaced the broad beta registry with `px_public_packages()` and
  `px_public_status()`.
- Trimmed `pharmax.ml` to R-native exploratory helpers that can be installed,
  tested, and reviewed without private strategy context.
- Hardened the public release safety check for private paths, data files,
  deferred package paths, and unsupported public claims.

## 0.1.0-alpha — 2026-05-26

- Added initial `pharmax.viz` package.
- Added initial `pharmax.ml` package.
