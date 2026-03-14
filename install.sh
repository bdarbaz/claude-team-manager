#!/bin/bash
set -e

AGENT_DIR="$HOME/.claude/agents"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Claude Team Manager - Installer ==="
echo ""

# Check prerequisites
echo "[1/4] Checking prerequisites..."

if ! command -v claude &> /dev/null; then
    echo "  ERROR: Claude Code is not installed."
    echo "  Install: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

CLAUDE_VERSION=$(claude --version 2>/dev/null | head -1 | grep -oP '[\d.]+' | head -1)
echo "  Claude Code: v$CLAUDE_VERSION"

if ! command -v tmux &> /dev/null; then
    echo "  WARNING: tmux is not installed. Split-pane mode won't work."
    echo "  Install: sudo apt install tmux (Ubuntu/Debian) or brew install tmux (macOS)"
else
    TMUX_VERSION=$(tmux -V | grep -oP '[\d.]+')
    echo "  tmux: v$TMUX_VERSION"
fi

# Enable agent teams
echo ""
echo "[2/4] Checking agent teams feature flag..."

SETTINGS_FILE="$HOME/.claude/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    if grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" "$SETTINGS_FILE"; then
        echo "  Agent teams already enabled."
    else
        echo "  Enabling CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS..."
        # Use node to safely modify JSON
        node -e "
            const fs = require('fs');
            const settings = JSON.parse(fs.readFileSync('$SETTINGS_FILE', 'utf8'));
            if (!settings.env) settings.env = {};
            settings.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = '1';
            fs.writeFileSync('$SETTINGS_FILE', JSON.stringify(settings, null, 2) + '\n');
        "
        echo "  Done."
    fi
else
    echo "  Creating settings.json with agent teams enabled..."
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    cat > "$SETTINGS_FILE" << 'SETTINGS'
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
SETTINGS
    echo "  Done."
fi

# Install agent
echo ""
echo "[3/4] Installing team-manager agent..."

mkdir -p "$AGENT_DIR"
cp "$SCRIPT_DIR/agents/team-manager.md" "$AGENT_DIR/team-manager.md"
echo "  Installed to $AGENT_DIR/team-manager.md"

# Configure tmux
echo ""
echo "[4/4] Configuring tmux..."

TMUX_CONF="$HOME/.tmux.conf"

if command -v tmux &> /dev/null; then
    NEEDS_MOUSE=true
    if [ -f "$TMUX_CONF" ] && grep -q "set -g mouse on" "$TMUX_CONF"; then
        NEEDS_MOUSE=false
    fi

    if [ "$NEEDS_MOUSE" = true ]; then
        echo "  Enabling mouse support in tmux..."
        echo "" >> "$TMUX_CONF"
        echo "# Claude Team Manager - mouse support" >> "$TMUX_CONF"
        echo "set -g mouse on" >> "$TMUX_CONF"
        echo "  Added 'set -g mouse on' to $TMUX_CONF"
    else
        echo "  Mouse support already enabled."
    fi

    # Apply immediately if tmux is running
    if tmux list-sessions &> /dev/null 2>&1; then
        tmux set-option -g mouse on 2>/dev/null || true
        echo "  Applied mouse setting to running tmux."
    fi
else
    echo "  Skipped (tmux not installed)."
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Usage:"
echo "  Interactive:  claude --agent team-manager"
echo "  One-shot:     claude -p --agent team-manager \"show status\""
echo ""
echo "Quick start:"
echo "  1. Start a tmux session:  tmux new -s myproject"
echo "  2. Inside tmux, start Claude:  claude --teammate-mode tmux"
echo "  3. Ask Claude to create an agent team"
echo "  4. Open another terminal and run:  claude --agent team-manager"
echo "  5. Manage your team from there!"
echo ""
