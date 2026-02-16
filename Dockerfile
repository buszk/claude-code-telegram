# ============================================================
# Claude Code Telegram Bot - Dockerfile
# Compatible with Unraid Docker management
# ============================================================

FROM python:3.12-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Set up virtual environment
ENV POETRY_VERSION=1.8.4
ENV POETRY_HOME=/opt/poetry
ENV POETRY_VENV=/opt/poetry/venv
ENV PATH="$POETRY_VENV/bin:$PATH"

WORKDIR /app

# Copy dependency files first for better caching
COPY pyproject.toml ./

# Install dependencies (without dev dependencies)
RUN poetry install --no-interaction --no-ansi --no-dev

# ============================================================
# Production image
# ============================================================
FROM python:3.12-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set up Poetry
ENV POETRY_VERSION=1.8.4
ENV POETRY_HOME=/opt/poetry
ENV POETRY_VENV=/opt/poetry/venv
ENV PATH="$POETRY_VENV/bin:$PATH"

# Create application directory
WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder $POETRY_VENV $POETRY_VENV

# Copy application source
COPY --from=builder /app/src /app/src
COPY --from=builder /app/pyproject.toml /app/

# Create data directory for SQLite database
RUN mkdir -p /data && chown -R root:root /app

# Create non-root user for security
RUN useradd -m -u 1000 -s /bin/bash appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
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
ENTRYPOINT ["python", "-m", "src.main"]
