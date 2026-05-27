# Security Policy

## Supported Versions

`pharmax` is currently in public proof-slice development. Security reports should
target the current `main` branch unless a tagged release is explicitly named.

## Reporting A Vulnerability

Please report suspected security issues through GitHub private vulnerability
reporting if available for this repository.

If private vulnerability reporting is unavailable, open a minimal public issue
that says a security report is available, but do not include secrets,
credentials, patient data, proprietary data, exploit details, or confidential
study information in the public issue.

## Data Safety

Do not upload or commit:

- `.env` files
- API keys, tokens, passwords, certificates, or private keys
- clinical trial datasets
- patient-level or subject-level data
- sponsor, employer, or proprietary project files
- NONMEM output folders or model output containing confidential data

## Expected Response

Security reports will be triaged for:

- affected package or workflow
- reproducibility
- risk to users or public infrastructure
- whether the report involves data exposure

This public proof-slice project does not yet provide formal service-level
agreements.
