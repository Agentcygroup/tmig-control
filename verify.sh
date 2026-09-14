#!/usr/bin/env bash
set -euo pipefail
fail=0
awk '
  /^\[\[repo\]\]/ { n++; next }
  /^name *=/      { gsub(/.*= *"|"/,""); name[n]=$0 }
  /^visibility *=/{ gsub(/.*= *"|"/,""); vis[n]=$0 }
  END { for (i=1;i<=n;i++) print name[i], vis[i] }
' org.toml | while read -r name vis; do
  actual=$(gh api "repos/Agentcygroup/$name" --jq '.private' 2>/dev/null || echo "missing")
  want=$([ "$vis" = private ] && echo true || echo false)
  if [ "$actual" != "$want" ]; then
    echo "DRIFT: $name private=$actual want=$want"; fail=1
  else
    echo "ok: $name private=$actual"
  fi
done
exit $fail
