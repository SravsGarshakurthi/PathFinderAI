#!/bin/bash
# Database Migration Script for PathFinder AI
# This script runs all database migrations in order

set -e  # Exit on error

echo "🚀 Running PathFinder AI Database Migrations..."

# Database connection details (matching docker-compose.yml)
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-pathfinder_secret}"
POSTGRES_DB="${POSTGRES_DB:-pathfinder_ai}"
POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"

# Check if running in Docker Compose context
if [ -f /.dockerenv ] || [ -n "$DOCKER_COMPOSE" ]; then
    POSTGRES_HOST="postgres"
    POSTGRES_PORT="5432"
fi

# Export password for psql
export PGPASSWORD="$POSTGRES_PASSWORD"

# Migration files in order
MIGRATIONS=(
    "backend/database/migrations/001_initial_schema.sql"
    "backend/database/migrations/002_pathfinder_profile.sql"
    "backend/database/migrations/003_add_job_salary.sql"
)

echo "📋 Database: $POSTGRES_DB"
echo "🔗 Host: $POSTGRES_HOST:$POSTGRES_PORT"
echo ""

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
until psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' 2>/dev/null; do
    echo "   PostgreSQL is unavailable - sleeping..."
    sleep 1
done
echo "✅ PostgreSQL is ready!"
echo ""

# Run each migration
for migration in "${MIGRATIONS[@]}"; do
    if [ ! -f "$migration" ]; then
        echo "❌ Migration file not found: $migration"
        exit 1
    fi
    
    echo "📝 Running migration: $(basename $migration)"
    psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$migration"
    
    if [ $? -eq 0 ]; then
        echo "✅ Migration completed: $(basename $migration)"
    else
        echo "❌ Migration failed: $(basename $migration)"
        exit 1
    fi
    echo ""
done

echo "🎉 All migrations completed successfully!"
echo ""
echo "📊 Verifying tables..."
psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\dt pathfinder_*" || true
echo ""
echo "✨ Database setup complete!"
