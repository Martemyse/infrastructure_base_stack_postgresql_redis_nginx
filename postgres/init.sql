CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Load custom functions (mounted from ./postgres/functions)
\i '/docker-entrypoint-initdb.d/functions/update_dynamic_weeks_mapping.sql'