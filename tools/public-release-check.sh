#!/usr/bin/env bash
set -euo pipefail

root="${1:-$(pwd)}"
cd "$root"

private_path_regex='(^|/)(_ADMIN|_Admin|\.claude|\.Codex|docs/(launch|superpowers|white-paper)|CLAUDE\.md|PLAN1\.md|ROADMAP\.md|\.env|\.env\.|\.Renviron|credentials\.json|.*\.(pem|key|p12|pfx)$)'
deferred_package_regex='(^|/)packages/pharmax\.(ai|api|app|valid|report|pk|nca|sim|data)(/|$)'
data_file_regex='\.(csv|xpt|sas7bdat|xlsx|xls|rds|rda|RData|parquet|fst|sav|dta)$'
claim_regex='pharmax\.(ai|api|app|valid|report)|SaaS|pricing|monetization|go-to-market|competitive strategy|multi-agent|multi agent|agentic|LLM|prompt|GxP|21 CFR|SOC[ -]?2|job-market|job market'

echo "== Pharmax public release check =="
echo "Repository: $root"

echo
echo "== Tracked private/local paths =="
if git ls-files | grep -E "$private_path_regex"; then
  echo "Public release check failed: tracked private/local paths found." >&2
  exit 1
fi

echo
echo "== Tracked deferred package paths =="
if git ls-files | grep -E "$deferred_package_regex"; then
  echo "Public release check failed: tracked deferred package paths found." >&2
  exit 1
fi

echo
echo "== Reachable history private/local paths =="
if git log --all --name-only --pretty=format: | sed '/^$/d' | grep -E "$private_path_regex"; then
  echo "Public release check failed: reachable Git history contains private/local paths." >&2
  exit 1
fi

echo
echo "== Reachable history deferred package paths =="
if git log --all --name-only --pretty=format: | sed '/^$/d' | grep -E "$deferred_package_regex"; then
  echo "Public release check failed: reachable Git history contains deferred package paths." >&2
  exit 1
fi

echo
echo "== Tracked data files =="
if git ls-files | grep -Ei "$data_file_regex"; then
  echo "Public release check failed: tracked data files found." >&2
  exit 1
fi

echo
echo "== Unsupported public claims =="
scan_paths=()
for path in README.md CHANGELOG.md index.html AGENTS.md docs packages .github; do
  if [ -e "$path" ]; then
    scan_paths+=("$path")
  fi
done

claim_hits="$(
  {
    rg -n -i "$claim_regex" "${scan_paths[@]}" \
      --glob '!**/docs/deps/**' \
      --glob '!**/docs/search.json' \
      --glob '!**/man/**' \
      || true
    rg -n '\bARR\b' "${scan_paths[@]}" \
    --glob '!**/docs/deps/**' \
    --glob '!**/docs/search.json' \
    --glob '!**/man/**' \
    || true
  }
)"

if [ -n "$claim_hits" ]; then
  unexpected_hits=""
  while IFS= read -r hit; do
    file="${hit%%:*}"
    rest="${hit#*:}"
    line="${rest%%:*}"
    start=$(( line > 8 ? line - 8 : 1 ))
    context="$(sed -n "${start},${line}p" "$file")"
    if printf '%s\n' "$hit" "$context" |
      rg -qi 'not allowed|outside this public repository|kept outside|forbidden|never commit|private repository|private/admin|safety check|not validated|not autonomous|no autonomous|do not use|do not claim|expect_false|expect_setequal'; then
      continue
    fi
    unexpected_hits="${unexpected_hits}${hit}"$'\n'
  done <<< "$claim_hits"
  if [ -n "$unexpected_hits" ]; then
    printf '%s\n' "$unexpected_hits"
    echo "Public release check failed: unsupported public claim language found." >&2
    exit 1
  fi
fi

echo
echo "== Required public package files =="
for pkg in \
  packages/pharmax \
  packages/pharmax.viz \
  packages/pharmax.ml
do
  test -f "$pkg/DESCRIPTION"
  test -f "$pkg/NAMESPACE"
  test -f "$pkg/README.md"
  test -f "$pkg/NEWS.md"
done

echo
echo "== Deferred public package files absent =="
for pkg in \
  packages/pharmax.ai \
  packages/pharmax.api \
  packages/pharmax.app \
  packages/pharmax.valid \
  packages/pharmax.report \
  packages/pharmax.pk \
  packages/pharmax.nca \
  packages/pharmax.sim \
  packages/pharmax.data
do
  if [ -e "$pkg" ]; then
    echo "Public release check failed: deferred package exists at $pkg." >&2
    exit 1
  fi
done

echo
echo "Public release check passed."
