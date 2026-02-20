# Database Commands Quick Reference

Quick reference for working with PostgreSQL database in Docker.

## 🔌 Connect to Database

**Interactive psql session:**
```bash
docker compose exec postgres psql -U postgres -d pathfinder_ai
```

Once connected, you can run SQL commands directly:
```sql
-- List all tables
\dt

-- List PathFinder tables
\dt pathfinder_*

-- Describe a table structure
\d pathfinder_users

-- Run a query
SELECT * FROM pathfinder_users LIMIT 10;

-- Exit psql
\q
```

## 📋 Common Commands

### List Tables
```bash
# All tables
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "\dt"

# PathFinder tables only
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "\dt pathfinder_*"
```

### Run Queries

**View all users:**
```bash
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "SELECT * FROM pathfinder_users;"
```

**Count records:**
```bash
# Count users
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "SELECT COUNT(*) FROM pathfinder_users;"

# Count jobs
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "SELECT COUNT(*) FROM pathfinder_jobs;"
```

**View user profiles:**
```bash
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "SELECT id, user_id, name FROM pathfinder_user_profiles LIMIT 5;"
```

**View jobs:**
```bash
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "SELECT id, title, company, location FROM pathfinder_jobs LIMIT 10;"
```

**View user documents:**
```bash
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "SELECT id, user_id, category, filename FROM pathfinder_user_documents;"
```

## 🔍 Useful Queries

### Check Database Schema
```bash
# List all tables with their schemas
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "\d+"
```

### View Table Structure
```bash
# Detailed structure of a table
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "\d pathfinder_users"
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "\d pathfinder_user_profiles"
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "\d pathfinder_jobs"
```

### Join Queries
```bash
# Users with their profiles
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "
SELECT u.id, u.email, u.name, p.technical_skills 
FROM pathfinder_users u 
LEFT JOIN pathfinder_user_profiles p ON u.id = p.user_id 
LIMIT 5;
"
```

### Search Queries
```bash
# Find jobs by keyword
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "
SELECT title, company, location 
FROM pathfinder_jobs 
WHERE title ILIKE '%engineer%' 
LIMIT 10;
"
```

## 📊 Database Info

**Check database size:**
```bash
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "
SELECT pg_size_pretty(pg_database_size('pathfinder_ai')) AS database_size;
"
```

**List all databases:**
```bash
docker compose exec postgres psql -U postgres -c "\l"
```

**Check PostgreSQL version:**
```bash
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "SELECT version();"
```

## ⚠️ Important Notes

- **Connection String:** The connection string (`postgresql+asyncpg://postgres:pathfinder_secret@postgres:5432/pathfinder_ai`) is only used internally by the backend application.
- **Direct Access:** Use `docker compose exec` commands for direct database access from the command line.
- **Interactive Mode:** Use `docker compose exec postgres psql -U postgres -d pathfinder_ai` for interactive SQL sessions.
- **One-liners:** Use `-c "SQL_COMMAND"` for single SQL commands without entering interactive mode.

## 🔐 Database Credentials

- **User:** `postgres`
- **Password:** `pathfinder_secret`
- **Database:** `pathfinder_ai`
- **Host:** `postgres` (internal Docker network) or `localhost` (from host)
- **Port:** `5432`

## 📚 Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [psql Command Reference](https://www.postgresql.org/docs/current/app-psql.html)
