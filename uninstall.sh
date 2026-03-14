#!/bin/bash
set -e

echo "=== Claude Team Manager - Uninstaller ==="
echo ""

AGENT_FILE="$HOME/.claude/agents/team-manager.md"

if [ -f "$AGENT_FILE" ]; then
    rm "$AGENT_FILE"
    echo "Removed: $AGENT_FILE"
else
    echo "Agent file not found (already removed?)."
fi

echo ""
echo "Note: tmux mouse setting and agent teams feature flag were left intact."
echo "To disable agent teams, remove CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS from ~/.claude/settings.json"
echo ""
echo "Uninstall complete."
