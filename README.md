# GastadorTracker Bot 💸

A **Telegram expense-tracking bot** for Philippine users. Log spending by
snapping a photo of a receipt (read automatically by AI) or typing it in
manually, and track your totals across GCash, Maya, Credit Card, Cash, and
other banks. All amounts are in **₱ (PHP)**.

---

## Tech stack

| Layer | Tech |
|---|---|
| Language | Python (single file, `bot.py`) |
| Bot framework | `python-telegram-bot` 21.5 (polling mode) |
| AI (receipt reading) | Anthropic Claude — model `claude-sonnet-4-6` |
| Database | Supabase (PostgreSQL) |
| Excel export | `openpyxl` |
| Hosting | Railway (nixpacks builder, `python bot.py`, auto-restart) |
| Deploy trigger | Push to `main` on GitHub → Railway redeploys |

---

## Environment variables (set these in Railway)

| Variable | Value |
|---|---|
| `TELEGRAM_TOKEN` | Your bot token from @BotFather |
| `SUPABASE_URL` | `https://ywwtllmqwcvlcqmtwoys.supabase.co` |
| `SUPABASE_KEY` | Your Supabase anon key |
| `ANTHROPIC_KEY` | Your Anthropic API key |

> ⚠️ If you regenerate the Telegram token in @BotFather, the old one dies
> immediately — update `TELEGRAM_TOKEN` in Railway and let it redeploy, or the
> bot will go silent.

---

## Database setup

Before running the bot, create the required tables in Supabase: run
[`schema.sql`](schema.sql) in the Supabase SQL Editor. It creates the `users`
and `expenses` tables and is safe to re-run.

### Data model

**`users`**

| Column | Type | Notes |
|---|---|---|
| `id` | bigint PK | Telegram user ID |
| `username` | text | |
| `first_name` | text | |
| `is_pro` | boolean | default `false`; set manually to grant Pro |
| `transaction_count` | integer | lifetime tally (not used for the limit) |
| `created_at` | timestamp | |

**`expenses`**

| Column | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `user_id` | bigint | Telegram user ID |
| `amount` | numeric | |
| `merchant` | text | |
| `wallet` | text | Cash / GCash / Maya / CreditCard / OtherBanks |
| `wallet_detail` | text | specific bank or card name (optional) |
| `date` | date | `YYYY-MM-DD` |
| `time` | time | `HH:MM:SS` |
| `entry_type` | text | `receipt` or `manual` |
| `created_at` | timestamp | |

Indexed on `(user_id, date)` and `(user_id, date, time)`.

> RLS (Row Level Security) is **off** — the bot is the only client and uses the
> anon key as a trusted backend.

---

## Features & user flows

**Persistent bottom keyboard (always visible):**
➕ Add Expense · 📊 My Spending · 📤 Export

### ➕ Add Expense
- **📸 Receipt Photo** — send a photo; Claude extracts amount, merchant,
  payment method, date and time → you confirm / edit / save.
- **✏️ Manual Entry** — type amount → merchant → pick wallet →
  (bank/card detail if needed) → confirm / save.
- The confirmation screen lets you **Edit** amount, merchant, wallet, or date
  before saving.

### 📸 Photo-first safety net
If you send a photo *without* going through the menu, the bot gently asks
*"Looks like a receipt! Want me to record this?"* (Yes / No) instead of
ignoring it. "Yes" reuses the normal receipt flow.

### 💳 Wallets supported
Cash, GCash, Maya, Credit Card, Other Banks (with a free-text bank/card name).

### 📊 My Spending
Landing shows **today's total + this month's total**, then:
- 📅 Today · 📆 This Week · 🗓️ This Month · 🔍 Pick a Date
- Each view shows itemized entries plus totals broken down by wallet.
- Empty periods show *"No expenses recorded yet for &lt;period&gt;. 🎉"*

### 📤 Export
Generates an **Excel (.xlsx)** file for Today / This Week / This Month / a
picked date.

### Commands (also in the ☰ input-bar menu)
| Command | Action |
|---|---|
| `/start` | Welcome message + keyboard |
| `/help` | Usage guide |
| `/undo` | Shows your last entry and asks to confirm before deleting it |

---

## Business model / limits
- **Free tier: 20 expenses per month**, counted live from the current calendar
  month — so it resets automatically on the 1st and stays correct after
  `/undo`.
- **Pro: unlimited** for ₱99/month. Upgrades are **manual** (set `is_pro = true`
  in the database). Upgrade contact shown in-bot: **@waxngcrsnt**.

---

## Behavior details
- **Timezone:** all dates/times use **Philippine time (UTC+8)**.
- **Privacy:** each user's data is isolated by their Telegram ID.
- **Error handling:** unreadable photos, invalid amounts, and unrecognized text
  all get friendly messages instead of silent failures; a global error handler
  logs exceptions to the Railway deploy logs.

---

## Known limitations / out of scope
1. **Receipt dates** use the date printed on the receipt, so an old receipt
   won't appear under "Today" (by design). Dateless/unreadable dates fall back
   to today and are flagged with a ⚠️ on the confirmation so you can edit them.
2. **Pro upgrades are manual** — there is no payment integration.
3. **Minor:** tapping a menu button *while the bot is waiting for typed input*
   can be captured as that input. Use `/cancel` or `/start` to get out.
4. **No categories, budgets, or reminders** (intentionally out of scope).

---

## Running locally
```bash
pip install -r requirements.txt
# export the 4 environment variables above, then:
python bot.py
```
The bot uses long polling — only **one** instance may run per token at a time
(a second poller causes Telegram `Conflict` errors and dropped updates).
