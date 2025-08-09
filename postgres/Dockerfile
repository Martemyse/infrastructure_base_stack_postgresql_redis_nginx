# Use the official PostgreSQL image as the base
FROM postgres:latest

# Install pg_cron and required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-contrib \
    postgresql-16-cron \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy custom PostgreSQL configuration
COPY postgresql.conf /etc/postgresql/postgresql.conf

# Set default command
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
