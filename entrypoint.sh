#!/bin/bash
set -e

# Write .env file from environment variables
echo "TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}" > /app/.env
echo "TELEGRAM_BOT_USERNAME=${TELEGRAM_BOT_USERNAME}" >> /app/.env
echo "APPROVED_DIRECTORY=${APPROVED_DIRECTORY:-/projects}" >> /app/.env
echo "ALLOWED_USERS=${ALLOWED_USERS:-}" >> /app/.env
echo "USE_SDK=${USE_SDK:-true}" >> /app/.env
echo "ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-}" >> /app/.env
echo "ENVIRONMENT=${ENVIRONMENT:-production}" >> /app/.env
echo "LOG_LEVEL=${LOG_LEVEL:-INFO}" >> /app/.env
echo "ENABLE_API_SERVER=${ENABLE_API_SERVER:-true}" >> /app/.env
echo "API_SERVER_PORT=${API_SERVER_PORT:-8080}" >> /app/.env
echo "ENABLE_MCP=${ENABLE_MCP:-false}" >> /app/.env
echo "ENABLE_GIT_INTEGRATION=${ENABLE_GIT_INTEGRATION:-true}" >> /app/.env
echo "ENABLE_FILE_UPLOADS=${ENABLE_FILE_UPLOADS:-true}" >> /app/.env
echo "ENABLE_QUICK_ACTIONS=${ENABLE_QUICK_ACTIONS:-true}" >> /app/.env
echo "AGENTIC_MODE=${AGENTIC_MODE:-true}" >> /app/.env
echo "DATABASE_URL=${DATABASE_URL:-sqlite:///data/bot.db}" >> /app/.env
echo "SESSION_TIMEOUT_HOURS=${SESSION_TIMEOUT_HOURS:-24}" >> /app/.env
echo "RATE_LIMIT_REQUESTS=${RATE_LIMIT_REQUESTS:-10}" >> /app/.env
echo "RATE_LIMIT_WINDOW=${RATE_LIMIT_WINDOW:-60}" >> /app/.env
echo "DEBUG=${DEBUG:-false}" >> /app/.env
echo "DEVELOPMENT_MODE=${DEVELOPMENT_MODE:-false}" >> /app/.env

# Debug: show user and permissions
echo "Running as: $(whoami)"
echo "User ID: $(id)"
ls -la /home/
ls -la /home/appuser/ 2>&1 || echo "Cannot list /home/appuser/"

# Write CLAUDE_SETTINGS_JSON if provided
if [ -n "$CLAUDE_SETTINGS_JSON" ]; then
    echo "Creating .claude directory..."
    mkdir -p /home/appuser/.claude
    ls -la /home/appuser/
    echo "Writing settings.json..."
    echo "$CLAUDE_SETTINGS_JSON" > /home/appuser/.claude/settings.json
    echo '{"hasCompletedOnboarding": true}' > /home/appuser/.claude.json
    ls -la /home/appuser/.claude/
fi

# Run the main application
exec python -m src.main "$@"
