-- Ensure the dynamic_weeks_mapping table exists
CREATE TABLE IF NOT EXISTS dynamic_weeks_mapping (
    time_bucket TEXT PRIMARY KEY,           -- Time bucket (e.g., -5T, +1T)
    start_date DATE NOT NULL,               -- Start date of the week (Monday)
    end_date DATE NOT NULL,                 -- End date of the week (Sunday)
    kt INT NOT NULL                         -- Week number of the year
);

-- Create or replace the function to update dynamic weeks mapping
CREATE OR REPLACE FUNCTION update_dynamic_weeks_mapping()
RETURNS VOID AS $$
DECLARE
    current_week_start DATE;
    start_date DATE;
    end_date DATE;
    time_bucket TEXT;
    kt INT;
    i INTEGER;
BEGIN
    -- Calculate the start date of the current week (Monday)
    current_week_start := CURRENT_DATE - ((EXTRACT(DOW FROM CURRENT_DATE)::INTEGER + 6) % 7);

    -- Clear existing mappings
    DELETE FROM dynamic_weeks_mapping;

    -- Generate new mappings for -5T to +2T
    FOR i IN -5..2 LOOP
        start_date := current_week_start + (i * 7);  -- Calculate start of the week (Monday)
        end_date := start_date + 6;                 -- End of the week (Sunday)
        time_bucket := CONCAT(CASE WHEN i >= 0 THEN '+' ELSE '' END, i::TEXT, 'T');
        kt := EXTRACT(WEEK FROM start_date);        -- Week number of the year

        -- Insert new mapping
        INSERT INTO dynamic_weeks_mapping (time_bucket, start_date, end_date, kt)
        VALUES (time_bucket, start_date, end_date, kt);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Schedule the function to run every Monday at 00:05
SELECT cron.schedule(
    'Update Dynamic Weeks Mapping',       -- Job name
    '5 0 * * 1',                          -- Every Monday at 00:05
    $$SELECT update_dynamic_weeks_mapping();$$
);
