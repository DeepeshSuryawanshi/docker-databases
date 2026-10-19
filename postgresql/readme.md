# PostgreSQL Docker Setup Guide

A quick user manual for running PostgreSQL with Docker Compose, using a named persistent volume.

## 1. Configuration

This setup uses:

- **PostgreSQL image:** `postgres:18.6`
- **Container name:** `main-postgres`
- **Database:** `main`
- **Username:** `postgress`
- **Password:** `postgress` (local development only)
- **Host port:** `5432`
- **Docker volume:** `main_postgres_data`

> **Security:** These credentials are simple and intended only for local development. Change them before using this setup in a shared or production environment. Avoid committing real passwords to source control.

## 2. Prerequisites

Install Docker Desktop (Windows/macOS) or Docker Engine with the Docker Compose plugin (Linux). Start Docker, then verify the installation:

```bash
docker --version
docker compose version
```

## 3. Create the project folder

Create a folder for the database configuration, then create a file named `docker-compose.yml` inside it:

```text
postgres-setup/
└── docker-compose.yml
```

## 4. Docker Compose configuration

Copy the following into `docker-compose.yml`:

```yaml
services:
  postgres:
    image: postgres:18.6
    container_name: main-postgres
    restart: unless-stopped

    environment:
      POSTGRES_DB: main
      POSTGRES_USER: postgress
      POSTGRES_PASSWORD: postgress

    ports:
      - "5432:5432"

    volumes:
      - main_postgres_data:/var/lib/postgresql

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgress -d main"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s

volumes:
  main_postgres_data:
    name: main_postgres_data
```

The named volume `main_postgres_data` stores database files outside the container's writable layer. The mount target `/var/lib/postgresql` is appropriate for the official PostgreSQL 18 image layout. Keep this mount path consistent with the image version.

## 5. Start PostgreSQL

Open a terminal in the folder containing `docker-compose.yml` and run:

```bash
# Download the configured image
docker compose pull

# Create and start the container in the background
docker compose up -d

# Check status and health
docker compose ps

# View startup logs
docker compose logs -f postgres
```

Press `Ctrl+C` to stop following logs; this does not stop the container.

## 6. Connect to the database

### Connection details

| Setting | Value |
|---|---|
| Host from your computer | `localhost` |
| Port | `5432` |
| Database | `main` |
| Username | `postgress` |
| Password | `postgress` |
| Connection URL | `postgresql://postgress:postgress@localhost:5432/main` |

Use the connection URL only in local development configuration. If your application is another service in the same Compose project/network, use `postgres` as the hostname instead of `localhost`:

```text
postgresql://postgress:postgress@postgres:5432/main
```

### Connect using `psql`

```bash
docker exec -it main-postgres psql -U postgress -d main
```

Run these SQL commands to verify the connection:

```sql
SELECT version();
SELECT current_database();
SELECT current_user;
```

Exit `psql` with:

```sql
\q
```

## 7. Common container commands

```bash
# Start services
docker compose up -d

# Stop services without deleting database data
docker compose stop

# Start stopped services
docker compose start

# Restart PostgreSQL
docker compose restart postgres

# Show status
docker compose ps

# Follow logs
docker compose logs -f postgres

# Stop and remove the container/network (named volume remains)
docker compose down

# Download the configured image and recreate the container
docker compose pull postgres
docker compose up -d --force-recreate postgres
```

## 8. Manage the named volume

```bash
# List Docker volumes
docker volume ls

# Inspect the volume
docker volume inspect main_postgres_data
```

The explicit `name:` setting makes the Docker volume name exactly `main_postgres_data`, without a Compose project-name prefix.

### Important: preserve data

- `docker compose down` removes the container and network, but **keeps** `main_postgres_data`.
- Recreating the container with the same named volume preserves the database files.
- Changing `POSTGRES_DB`, `POSTGRES_USER`, or `POSTGRES_PASSWORD` in the Compose file does **not** automatically change an already-initialized database or its credentials. Update existing database roles/settings with SQL as appropriate.
- Do not delete or rename the volume unless you intend to migrate or restore the data.

### Destructive reset — deletes database data

**Only do this if you intentionally want to permanently remove the local database data.** First stop the Compose project, then remove the named volume:

```bash
docker compose down
docker volume rm main_postgres_data
```

Then initialize a fresh database:

```bash
docker compose up -d
```

Removing a volume permanently deletes its stored database files. Back up important data first.

## 9. Back up and restore

Create a logical backup of the `main` database:

```bash
docker exec -t main-postgres pg_dump -U postgress -d main > main-backup.sql
```

Restore into an existing empty database:

```bash
docker exec -i main-postgres psql -U postgress -d main < main-backup.sql
```

Keep backups outside the container and test restores periodically. Do not restore a backup over important live data without a recovery plan.

## 10. Troubleshooting

### Port 5432 is already in use

Change the host-side port in Compose, for example:

```yaml
ports:
  - "5433:5432"
```

Then connect from your computer using port `5433`. Other Compose services should still use `postgres:5432`.

### Container is not healthy or keeps restarting

```bash
docker compose ps
docker compose logs --tail=100 postgres
```

Review the error before removing containers or volumes.

### Password or database changes are not taking effect

The `POSTGRES_*` initialization variables apply when the data directory is first initialized. For an existing volume, change the database role/password or database using SQL, or intentionally recreate the volume only after backing up data.

### Application cannot connect

- From your computer: use `localhost:5432` (or the changed host port).
- From another Compose service: use hostname `postgres` and container port `5432`.
- Confirm the container is running and healthy with `docker compose ps`.
- Confirm the application and database share a Docker network when using the service hostname.

## 11. Production notes

This example is for local development. For production, use a strong unique password, keep secrets out of committed Compose files (for example, use an appropriate secret-management approach), restrict network exposure, configure backups and monitoring, and plan PostgreSQL upgrades. Pin and test a specific supported image version rather than relying on `latest`.
