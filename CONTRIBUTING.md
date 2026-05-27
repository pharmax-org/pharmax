# Contributing to pharmax

Thank you for considering a contribution. `pharmax` is a public proof-slice, so
the best contributions are small, reproducible, and easy to review.

## Scope

Current public package scope:

- `packages/pharmax`: public package status and coordination helpers
- `packages/pharmax.viz`: pharmacometric visualization helpers
- `packages/pharmax.ml`: R-native exploratory ML helpers

Please do not add clinical, sponsor, employer, patient-level, or proprietary
data to issues, examples, tests, screenshots, or pull requests.

## Good First Contributions

- documentation fixes
- examples using public or synthetic data
- tests for existing exported functions
- small plot or report usability improvements
- bug reports with a minimal reproducible example

## Development Checks

Run the public safety check before opening a pull request:

```bash
bash tools/public-release-check.sh "$PWD"
```

Run package checks for the package you changed:

```bash
cd packages/pharmax.viz
R -q -e 'devtools::test(); devtools::check(error_on = "never")'
```

```bash
cd packages/pharmax.ml
R -q -e 'devtools::test(); devtools::check(error_on = "never")'
```

For coordinator-only changes:

```bash
cd packages/pharmax
R -q -e 'devtools::test(); devtools::check(error_on = "never")'
```

## Pull Request Expectations

- Keep the change focused.
- Use public or synthetic data only.
- Add or update tests for behavior changes.
- Update documentation when exported behavior changes.
- Avoid unsupported claims such as "FDA-ready", "validated for regulatory
  submission", or "replacement for NONMEM/Pumas/Certara/nlmixr2".

## Regulatory Language

Use:

- exploratory decision support
- regulatory-aware evidence structure
- human-reviewed workflows
- synthetic/public examples

Do not claim formal regulatory validation unless formal validation evidence has
actually been produced and reviewed.
