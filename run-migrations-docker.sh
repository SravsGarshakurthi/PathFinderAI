#!/bin/bash
# Run migrations using Docker Compose
# This script executes migrations inside the postgres container

set -e

echo "🚀 Running PathFinder AI Database Migrations via Docker..."

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose not found. Please install Docker Compose."
    exit 1
fi

# Use docker compose (v2) or docker-compose (v1)
DOCKER_COMPOSE_CMD="docker compose"
if ! $DOCKER_COMPOSE_CMD version &> /dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker-compose"
fi

echo "📋 Using: $DOCKER_COMPOSE_CMD"
echo ""

# Ensure postgres is running
echo "⏳ Ensuring PostgreSQL is running..."
$DOCKER_COMPOSE_CMD up -d postgres

# Wait for postgres to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if $DOCKER_COMPOSE_CMD exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
        echo "✅ PostgreSQL is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ PostgreSQL failed to start"
        exit 1
    fi
    sleep 1
done

# Migration files
MIGRATIONS=(
    "backend/database/migrations/001_initial_schema.sql"
    "backend/database/migrations/002_pathfinder_profile.sql"
    "backend/database/migrations/003_add_job_salary.sql"
)

# Run each migration
for migration in "${MIGRATIONS[@]}"; do
    if [ ! -f "$migration" ]; then
        echo "❌ Migration file not found: $migration"
        exit 1
    fi
    
    echo "📝 Running migration: $(basename $migration)"
    $DOCKER_COMPOSE_CMD exec -T postgres psql -U postgres -d pathfinder_ai < "$migration"
    
    if [ $? -eq 0 ]; then
        echo "✅ Migration completed: $(basename $migration)"
    else
        echo "❌ Migration failed: $(basename $migration)"
        exit 1
    fi
    echo ""
done

echo "🎉 All migrations completed!"
echo ""
echo "📊 Verifying tables..."
$DOCKER_COMPOSE_CMD exec postgres psql -U postgres -d pathfinder_ai -c "\dt pathfinder_*" || true
echo ""
echo "✨ Database setup complete!"
