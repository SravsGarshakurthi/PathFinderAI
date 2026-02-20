# VM Development Workflow

This document describes the workflow for developing PathFinder AI directly on the VM.

## 🔐 SSH Access

Connect to the VM:
```bash
ssh -i /Users/nani/Downloads/SheCodesTrio.pem linux1@148.100.112.119
```

## 📂 Navigate to Project

```bash
cd ~/pathfinder-ai
```

## ✏️ Edit Files

### Using Terminal Editors

**Nano (beginner-friendly):**
```bash
nano backend/app/api/v1/career.py
# Ctrl+X to exit, Y to save, Enter to confirm
```

**Vim (advanced):**
```bash
vim backend/app/api/v1/career.py
# Press 'i' to insert, ESC then ':wq' to save and quit
```

### Using VS Code Remote SSH (Recommended)

1. **Install VS Code Remote SSH extension** on your Mac
2. **Connect to VM:**
   - Press `Cmd+Shift+P`
   - Type "Remote-SSH: Connect to Host"
   - Enter: `linux1@148.100.112.119`
   - Select the SSH config or enter the full command
3. **Open project folder:** `/home/linux1/pathfinder-ai`
4. **Edit files** directly in VS Code as if they were local!

## 🔄 Rebuild and Restart Containers

After making changes to backend code:

```bash
# Rebuild the backend container
docker compose build backend

# Restart services
docker compose up -d

# View logs to verify
docker compose logs -f backend
```

**Note:** Frontend changes may require rebuilding the frontend container:
```bash
docker compose build frontend
docker compose up -d frontend
```

## 📝 Git Workflow

**Important:** Always use git to save and share changes to avoid overwriting each other's work.

### Save Your Changes
```bash
# Check what changed
git status

# Stage changes
git add .

# Commit with descriptive message
git commit -m "Add new feature: career matching algorithm"

# Push to remote repository
git push
```

### Pull Latest Changes
```bash
# Pull latest changes from remote
git pull

# If there are conflicts, resolve them, then:
git add .
git commit -m "Merge conflicts resolved"
git push
```

### Best Practices
- **Always pull before starting work:** `git pull`
- **Commit frequently** with clear messages
- **Push regularly** so others can see your changes
- **Don't force push** to main/master branch

## 🚀 Quick Reference Commands

### Docker Management
```bash
# View running containers
docker compose ps

# View logs
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f postgres

# Stop all services
docker compose down

# Start all services
docker compose up -d

# Rebuild specific service
docker compose build backend
docker compose build frontend

# Restart specific service
docker compose restart backend
```

### Database Management

**Connect to PostgreSQL (interactive shell):**
```bash
docker compose exec postgres psql -U postgres -d pathfinder_ai
```

**List all tables:**
```bash
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "\dt"
```

**List PathFinder tables only:**
```bash
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "\dt pathfinder_*"
```

**Run a query:**
```bash
# Example: View all users
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "SELECT * FROM pathfinder_users;"

# Example: Count jobs
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "SELECT COUNT(*) FROM pathfinder_jobs;"

# Example: View user profiles
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "SELECT * FROM pathfinder_user_profiles LIMIT 5;"
```

**Useful psql commands (when in interactive mode):**
```sql
-- List tables
\dt

-- Describe table structure
\d pathfinder_users

-- List all databases
\l

-- Exit psql
\q
```

**Database Migrations:**
```bash
# Run migrations (if not already done)
./run-migrations-docker.sh

# Check database tables
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "\dt"
```

**Note:** The connection string (`postgresql+asyncpg://postgres:pathfinder_secret@postgres:5432/pathfinder_ai`) is only used internally by the backend application. For direct database access, use the `docker compose exec` commands above.

### File Management
```bash
# View file contents
cat backend/app/main.py

# Search in files
grep -r "function_name" backend/

# Find files
find . -name "*.py" -type f
```

## 🎯 Typical Development Flow

1. **SSH into VM**
   ```bash
   ssh -i /Users/nani/Downloads/SheCodesTrio.pem linux1@148.100.112.119
   ```

2. **Navigate to project**
   ```bash
   cd ~/pathfinder-ai
   ```

3. **Pull latest changes**
   ```bash
   git pull
   ```

4. **Make your changes**
   - Edit files using nano/vim or VS Code Remote SSH
   - Test your changes locally

5. **Rebuild and restart** (if backend changed)
   ```bash
   docker compose build backend
   docker compose up -d
   ```

6. **Test your changes**
   - Check logs: `docker compose logs -f backend`
   - Test API: `curl http://localhost:8000/health`
   - Test frontend: Visit `http://148.100.112.119:5173`

7. **Commit and push**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push
   ```

## ⚠️ Important Notes

- **Changes take effect immediately** after rebuilding and restarting containers
- **Always use git** to avoid losing work or overwriting others' changes
- **VS Code Remote SSH** provides the best editing experience
- **Test locally** before pushing to avoid breaking the shared environment
- **Check logs** if something doesn't work: `docker compose logs -f [service]`

## 🔍 Troubleshooting

### Container won't start
```bash
# Check logs
docker compose logs backend

# Rebuild from scratch
docker compose build --no-cache backend
docker compose up -d
```

### Database connection issues
```bash
# Check if postgres is running
docker compose ps postgres

# Check postgres logs
docker compose logs postgres

# Test connection
docker compose exec postgres psql -U postgres -d pathfinder_ai -c "SELECT 1;"

# Connect interactively to troubleshoot
docker compose exec postgres psql -U postgres -d pathfinder_ai
```

### Port already in use
```bash
# Find what's using the port
sudo lsof -i :8000

# Or change port in docker-compose.yml
```

## 📚 Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [VS Code Remote SSH](https://code.visualstudio.com/docs/remote/ssh)
- [Git Basics](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)
