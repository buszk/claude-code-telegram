# ============================================================
# Claude Code Telegram Bot - Dockerfile
# Compatible with Unraid Docker management
# ============================================================

FROM python:3.12-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry globally
RUN pip install --no-cache-dir poetry==1.8.4

WORKDIR /app

# Copy dependency files
COPY pyproject.toml ./

# Install dependencies (without installing the current project)
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi --no-dev --no-root

# Copy source code
COPY src/ ./src/

# ============================================================
# Production image
# ============================================================
FROM python:3.12-slim

# Install runtime dependencies including Node.js for Claude CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gosu \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Claude CLI
RUN npm install -g @anthropic-ai/claude-code

# Install Poetry for running the app
RUN pip install --no-cache-dir poetry==1.8.4

# Create application directory
WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application source
COPY --from=builder /app/src /app/src
COPY --from=builder /app/pyproject.toml /app/

# Copy and set up entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create non-root user for security
RUN useradd -m -u 1000 -s /bin/bash appuser

# Create data directory and set permissions
RUN mkdir -p /data /home/appuser/.claude && chown -R appuser:appuser /app /data /home/appuser/.claude

# Run as appuser
USER appuser

# Expose API server port (default 8080)
EXPOSE 8080

# Default environment variables
ENV PYTHONUNBUFFERED=1 \
    ENVIRONMENT=production \
    LOG_LEVEL=INFO

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Entry point
ENTRYPOINT ["/entrypoint.sh"]
