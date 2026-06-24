-- GastadorTrackerBot — Supabase / PostgreSQL schema
--
-- This file documents the tables the bot uses. It mirrors the live Supabase
-- project (verified via information_schema), so the column types, nullability
-- and defaults below match what is already deployed.
--
-- The live tables already exist, so the CREATE statements use IF NOT EXISTS and
-- are no-ops against the current database; they're here so the schema can be
-- recreated from scratch (e.g. a fresh project) and matches production.
--
-- Source of the column definitions: bot.py (get_or_create_user, get_user,
-- increment_count, check_limit, save_expense, and the spending/export queries).

-- ---------------------------------------------------------------------------
-- users
-- ---------------------------------------------------------------------------
-- "id" is the Telegram user id (bigint — Telegram ids exceed the 32-bit range).
-- get_or_create_user inserts only {id, username, first_name}; is_pro and
-- transaction_count therefore rely on their column defaults for new rows.
CREATE TABLE IF NOT EXISTS public.users (
    id                bigint    PRIMARY KEY,
    username          text,
    first_name        text,
    is_pro            boolean   NOT NULL DEFAULT false,
    transaction_count integer   NOT NULL DEFAULT 0,
    created_at        timestamp NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- expenses
-- ---------------------------------------------------------------------------
-- The bot stores date as "YYYY-MM-DD" and time as "HH:MM:SS" strings; the
-- date / time column types accept those formats directly, and the bot's
-- gte/lte/eq filters on the date column work as expected.
--
-- user_id is nullable in the live DB. A foreign key to users(id) is recommended
-- but is not currently enforced in production; uncomment the REFERENCES clause
-- if you want referential integrity on a fresh setup.
CREATE TABLE IF NOT EXISTS public.expenses (
    id            uuid      PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       bigint    , -- REFERENCES public.users(id) ON DELETE CASCADE
    amount        numeric   NOT NULL,
    merchant      text      NOT NULL,
    wallet        text      NOT NULL,
    wallet_detail text,
    date          date      NOT NULL,
    time          time      NOT NULL,
    entry_type    text,          -- 'receipt' or 'manual'
    created_at    timestamp NOT NULL DEFAULT now()
);

-- Indexes for the spending/export queries, which always filter by user_id and
-- range/equality on date, often ordered by date or time.
CREATE INDEX IF NOT EXISTS expenses_user_date_idx ON public.expenses (user_id, date);
CREATE INDEX IF NOT EXISTS expenses_user_date_time_idx ON public.expenses (user_id, date, time);
