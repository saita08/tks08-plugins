#!/usr/bin/env bash
# parallel-fix: remove the run's ledger from the project.
#
# The ledger, .claude/parallel-fix.local.md at the repository root, is the
# fellow's working record for one run. It belongs to the project while the run
# is alive and to nobody afterwards, so the run ends by removing it. A ledger
# that is still there when the command starts is how an unfinished run is
# recognized, which is why nothing else may delete it.
#
# Prints one line saying what happened. Exits 0 when the ledger is gone or was
# never there, 1 when it was left in place.

set -euo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "not inside a git repository; nothing removed" >&2
  exit 1
}
ledger="${root}/.claude/parallel-fix.local.md"

if [ ! -e "$ledger" ]; then
  echo "no ledger at ${ledger}"
  exit 0
fi

# A tracked ledger means someone committed it. Deleting it here would stage a
# removal the user never asked for, so leave it and say so.
if git -C "$root" ls-files --error-unmatch -- ".claude/parallel-fix.local.md" >/dev/null 2>&1; then
  echo "ledger is tracked by git; left in place: ${ledger}" >&2
  exit 1
fi

rm -- "$ledger"
echo "removed ${ledger}"
