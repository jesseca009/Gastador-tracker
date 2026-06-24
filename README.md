# GastadorTrackerBot 💸

A Telegram bot to track your daily expenses across GCash, Maya, Credit Card, and Cash.

## Environment Variables (set these in Railway)

| Variable | Value |
|---|---|
| TELEGRAM_TOKEN | Your bot token from @BotFather |
| SUPABASE_URL | https://ywwtllmqwcvlcqmtwoys.supabase.co |
| SUPABASE_KEY | Your Supabase anon key |
| ANTHROPIC_KEY | Your Anthropic API key |

## Database Setup

Before running the bot, create the required tables in Supabase:
run [`schema.sql`](schema.sql) in the Supabase SQL Editor. It creates the
`users` and `expenses` tables and is safe to re-run.

## Features
- 📸 Receipt photo reading via AI
- ✏️ Manual expense entry
- 💳 GCash, Maya, Cash, Credit Card, Other Banks
- 📊 Today / This Week / This Month / Pick a Date views
- 📤 Export to Excel
- 🔒 Per-user accounts via Telegram ID
- 🆓 20 free expenses/month, Pro = unlimited
