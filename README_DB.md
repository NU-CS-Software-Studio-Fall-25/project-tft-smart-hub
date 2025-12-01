# Backend Database Schema (Rails API)

Schema source: `ruby_backend/tft_team_builder/db/schema.rb` (PostgreSQL with `plpgsql` extension).

- **champions**
  - `id` (PK), `name` string, `tier` integer, `traits` string (slash-delimited list), `image_url` string
  - Sprite/meta: `sprite_name` string, `sprite_x/y/w/h` integers
  - External refs: `api_id` string, `set_identifier` string, `cost` integer
  - Timestamps: `created_at`, `updated_at`
  - Indexes: `set_identifier` (non-unique), unique `set_identifier + api_id`

- **traits**
  - `id` (PK), `api_id` string, `name` string
  - Sprite fields: `image_full`, `image_sprite`, `image_x/y/w/h` integers
  - `set_identifier` string
  - Timestamps: `created_at`, `updated_at`
  - Index: `set_identifier + api_id`

- **users**
  - `id` (PK), `email` string (required, unique), `password_digest` string (required)
  - Profile: `display_name` string, `bio` text, `location` string, `avatar_url` string
  - Auth/meta: `role` string default `"user"` (indexed), `provider` string, `uid` string
  - Email verification/reset: `email_verification_token` string, `email_verification_sent_at` datetime, `email_verified_at` datetime, `reset_password_token` string, `reset_password_sent_at` datetime
  - Timestamps: `created_at`, `updated_at`
  - Indexes: unique `email`, unique `provider + uid`, unique `reset_password_token`

- **team_comps**
  - `id` (PK), `user_id` integer (creator, nullable)
  - Core fields: `name` string, `description` text, `champions` string (CSV of names)
  - Stats/meta: `win_rate` decimal(5,4), `play_rate` decimal(5,4), `play_count` integer, `win_count` integer, `top4_count` integer, `avg_placement` decimal(4,2)
  - Top rate splits: `top1_rate`, `top2_rate`, `top3_rate`, `top4_rate` (all decimal(5,4))
  - Other: `notes` text, `source` string, `set_identifier` string, `composition_key` string, `composition_hash` string, `size` integer, `team_type` string default `"user"`
  - Cached counters: `likes_count` integer default 0, `favorites_count` integer default 0, `comments_count` integer default 0
  - Raw ingest: `raw_data` jsonb default `{}` not null
  - Timestamps: `created_at`, `updated_at`
  - Indexes: unique `composition_hash`; `composition_key`; `set_identifier`; `play_count`; `play_rate`; `win_rate`; composite `win_rate + created_at`; lowercased `name`

- **comments**
  - `id` (PK), `user_id` bigint (FK users, required), `team_comp_id` bigint (FK team_comps, required)
  - `content` text
  - Timestamps: `created_at`, `updated_at` (indexed on `created_at`)
  - Indexes: `team_comp_id`, `user_id`

- **likes**
  - `id` (PK), `user_id` bigint (FK users, required), `team_comp_id` bigint (FK team_comps, required)
  - Timestamps: `created_at`, `updated_at`
  - Indexes: unique `user_id + team_comp_id`; `team_comp_id`; `user_id`

- **favorites**
  - `id` (PK), `user_id` bigint (FK users, required), `team_comp_id` bigint (FK team_comps, required)
  - Timestamps: `created_at`, `updated_at`
  - Indexes: unique `user_id + team_comp_id`; `team_comp_id`; `user_id`

- **pending_registrations**
  - `id` (PK), `email` string (required, unique), `password_digest` string (required), `display_name` string
  - Verification: `verification_code` string (required), `code_sent_at` datetime (required), `expires_at` datetime (required)
  - Timestamps: `created_at`, `updated_at`
  - Indexes: unique `email`; `verification_code`; `expires_at`
