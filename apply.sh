#!/usr/bin/env bash
set -euo pipefail
# parse org.toml minimally
awk '
  /^\[\[repo\]\]/ { n++; next }
  /^name *=/      { gsub(/.*= *"|"/,""); name[n]=$0 }
  /^visibility *=/{ gsub(/.*= *"|"/,""); vis[n]=$0 }
  /^required_approvals *=/ { gsub(/.*= */,""); appr[n]=$0 }
  END { for (i=1;i<=n;i++) print name[i], vis[i], appr[i] }
' org.toml | while read -r name vis appr; do
  echo "== $name =="
  gh api -X PATCH "repos/Agentcygroup/$name" -f "private=$([ "$vis" = private ] && echo true || echo false)" >/dev/null
  gh api -X PUT  "repos/Agentcygroup/$name/branches/main/protection" \
    -f "required_status_checks[strict]=true" \
    -f "required_status_checks[contexts][]=gate" \
    -f "enforce_admins=false" \
    -f "required_pull_request_reviews[required_approving_review_count]=$appr" >/dev/null
  echo "  applied"
done
