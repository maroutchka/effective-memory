#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

REPO_URL="https://github.com/ComposioHQ/awesome-claude-skills.git"
CLONE_DIR="/tmp/awesome-claude-skills"
SKILLS_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/skills"

mkdir -p "$SKILLS_DIR"

# Clone or update the repo
if [ -d "$CLONE_DIR/.git" ]; then
  git -C "$CLONE_DIR" pull --ff-only --quiet
else
  git clone --depth=1 --quiet "$REPO_URL" "$CLONE_DIR"
fi

# Install top-level skills (skip composio-skills, connect-apps-plugin, and non-skill dirs)
SKIP_DIRS="composio-skills connect-apps-plugin connect connect-apps"

for skill_dir in "$CLONE_DIR"/*/; do
  skill_name=$(basename "$skill_dir")

  # Skip non-skill directories
  skip=false
  for skip_name in $SKIP_DIRS; do
    if [ "$skill_name" = "$skip_name" ]; then
      skip=true
      break
    fi
  done
  $skip && continue

  # Only install if SKILL.md exists
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    continue
  fi

  # Don't overwrite existing project skills
  if [ -d "$SKILLS_DIR/$skill_name" ]; then
    continue
  fi

  cp -r "$skill_dir" "$SKILLS_DIR/$skill_name"
  echo "Installed skill: $skill_name"
done

echo "awesome-claude-skills installation complete."
