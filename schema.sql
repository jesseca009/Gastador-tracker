-- GastadorTrackerBot — Supabase / PostgreSQL schema
--
-- Run this in the Supabase SQL Editor (or via psql) to create the tables the
-- bot expects. Safe to re-run: every statement uses IF NOT EXISTS.
--
-- Tables are derived from bot.py:
--   users     -> get_or_create_user, get_user, increment_count, check_limit
--   expenses  -> save_expense and the various spending/export queries

-- ---------------------------------------------------------------------------
-- users
-- ---------------------------------------------------------------------------
-- "id" is the Telegram user id. Telegram ids can exceed the 32-bit range, so
-- bigint is required. The bot inserts {id, username, first_name} and relies on
-- is_pro / transaction_count defaulting for new rows.
CREATE TABLE IF NOT EXISTS public.users (
    id                bigint      PRIMARY KEY,
    username          text,
    first_name        text,
    is_pro            boolean     NOT NULL DEFAULT false,
    transaction_count integer     NOT NULL DEFAULT 0,
    created_at        timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- expenses
-- ---------------------------------------------------------------------------
-- The bot stores date as "YYYY-MM-DD" and time as "HH:MM:SS" strings; the
-- date/time column types below accept those formats directly and the bot's
-- gte/lte/eq filters on the date column work as expected.
CREATE TABLE IF NOT EXISTS public.expenses (
    id            bigint        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id       bigint        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    amount        numeric(12,2) NOT NULL,
    merchant      text,
    wallet        text,
    wallet_detail text,
    date          date          NOT NULL,
    time          time,
    entry_type    text,          -- 'receipt' or 'manual'
    created_at    timestamptz   NOT NULL DEFAULT now()
);

-- Indexes for the spending/export queries, which always filter by user_id and
-- range/equality on date, often ordered by date or time.
CREATE INDEX IF NOT EXISTS expenses_user_date_idx ON public.expenses (user_id, date);
CREATE INDEX IF NOT EXISTS expenses_user_date_time_idx ON public.expenses (user_id, date, time);
