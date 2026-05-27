# AGENTS.md - pharmax public repository

This repository is public. Treat every tracked file, commit, branch, tag, release,
and GitHub Pages artifact as internet-visible.

## Public Scope

Allowed here:

- R package source under `packages/`
- GitHub Actions, issue templates, and public contribution metadata under `.github/`
- Public README, changelog, license, citation, contributing, security, and support files
- Public site, generated package docs, and synthetic/public proof assets
- Public release safety tooling under `tools/`

Not allowed here:

- `_ADMIN/`, `_Admin/`, private planning docs, launch drafts, or strategy notes
- `.claude/`, `.Codex/`, local agent settings, local MCP settings, or private automation rules
- `.env`, credentials, tokens, keys, certificates, or local configuration
- Clinical, sponsor, proprietary, patient-level, or non-public datasets
- Pricing, monetization, go-to-market, competitive strategy, or future internal planning detail

## Before Committing

Run:

```bash
bash tools/public-release-check.sh .
```

Plain English: this script checks that private folders, local settings, data
files, and unsupported claims are not being committed to the public repo.

## Private Repository

Internal planning and strategy belong in the private repository:

```text
pharmax-org/pharmax-Admin
```

If a file feels useful to agents but not useful to outside contributors, put it
in the private repo first.
