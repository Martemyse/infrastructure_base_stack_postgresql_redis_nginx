# Infrastructure: PostgreSQL + Redis + Nginx (reverse proxy) + Portainer + RabbitMQ

Production-ready Docker Compose setup to run a PostgreSQL instance (with pg_cron, pg_vector), a Redis instance with a custom config, an Nginx reverse proxy that fronts your app containers, Portainer for Docker management, and RabbitMQ with the management UI.

This repository is designed to be portable across OSes and easy to showcase on GitHub/Upwork. It avoids OS-specific paths and keeps secrets out of version control.

## Quick start

- Prerequisites: Docker and Docker Compose
- Create the external Docker network once (used to connect to other app containers):
  ```bash
  docker network create postgres_network
  ```
- Create your environment file from the example and set a strong password:
  ```bash
  cp .env.example .env  # or: cp env.example .env
  # edit .env
  ```
- Bring the stack up:
  ```bash
  docker compose up -d
  ```

## Services

- PostgreSQL (`postgres_c`)
  - Persists data in `postgres/postgres-data`
  - Loads `postgresql.conf` and initializes extensions via `init.sql`
  - Includes `pg_cron` for scheduled jobs
- Redis (`redis_c`)
  - Uses custom `redis.conf` baked via `redis/Dockerfile`
  - Persists data in `redis/data`
- Nginx (`nginx_c`)
  - Reverse proxy to your app containers
  - Serves static assets from `./volumes/static/*`
  - Swap `nginx/nginx.conf` with `nginx/nginx_ssl.conf` for HTTPS (provide your own certs)
- Portainer (`portainer_c`)
  - Web UI on port 9000
- RabbitMQ (`rabbitmq`)
  - AMQP on 5672, management UI on 15672

## Networking model

This compose uses an external Docker network named `postgres_network` so it can communicate with your other app containers (e.g., a Django app `django_c` and a Dash app `dashapp_urnioutput`). Ensure those app containers join the same network and expose the expected ports.

- Create the network once:
  ```bash
  docker network create postgres_network
  ```
- Ensure your other app compose files include:
  ```yaml
  networks:
    default:
      external: true
      name: postgres_network
  ```

The default Nginx config proxies to hosts `django_c:8010` and `dashapp_urnioutput:8089`. Update the upstreams in `nginx/nginx.conf` if your services differ.

## Configuration

- Environment variables: `.env`
  - `POSTGRES_PASSWORD` is required. Do not commit `.env`.
- Static files:
  - Place static assets into `./volumes/static/django_c` and `./volumes/static/dashapp_urnioutput` (these are mounted into Nginx).
- PostgreSQL:
  - Customize `postgres/postgresql.conf`.
  - Add SQL to `postgres/init.sql` to enable extensions or seed data.
- Redis:
  - Customize `redis/redis.conf`. The image is built from `redis/Dockerfile` and uses that config by default.
- Nginx SSL:
  - To enable SSL, switch the mount to `nginx/nginx_ssl.conf` in `docker-compose.yml` and provide your cert/key at the paths referenced in that file (or adjust accordingly).

## Data persistence

- PostgreSQL data: `postgres/postgres-data`
- Redis data: `redis/data`
- Portainer data: named volume `portainer_data` (Docker-managed)

These paths are ignored by Git but persisted across container restarts.

## Common commands

```bash
# Start services
docker compose up -d

# View logs
docker compose logs -f --tail=100

# Stop services
docker compose down

# Rebuild (if you change Dockerfiles)
docker compose build --no-cache && docker compose up -d
```

## Security notes

- Never commit `.env` or any real credentials to Git.
- Use strong, unique passwords for databases and management UIs.
- Validate Nginx reverse proxy targets to ensure only intended services are exposed.

## License

MIT – see `LICENSE`.

## Structure

```
.
├─ docker-compose.yml
├─ nginx/
│  ├─ nginx.conf
│  └─ nginx_ssl.conf
├─ postgres/
│  ├─ Dockerfile
│  ├─ postgresql.conf
│  ├─ init.sql
│  └─ functions/
├─ redis/
│  ├─ Dockerfile
│  ├─ redis.conf
│  └─ data/
└─ volumes/
   └─ static/
      ├─ django_c/
      └─ dashapp_urnioutput/
```

---

If you are reviewing this on Upwork/GitHub: this repository demonstrates secure, portable Docker infrastructure with clean documentation and Git hygiene suitable for production or staging use.
