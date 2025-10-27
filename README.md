# TFT Team Builder & Smart Compare

# Temporary Link: <https://tft-smartcomp-b3f1e37435eb.herokuapp.com/>

## How To Run Locally
- Prerequisites: `Ruby 3.4+`, `Node.js 18+` (tested with Node 20), `PostgreSQL 14+`, `bundler`, `npm`.
- Backend (Rails API):
  ```bash
  cd ruby_backend/tft_team_builder
  bundle install
  bundle exec rails db:create db:migrate db:seed
  bundle exec rails server # http://localhost:3000
  ```
- Frontend (Vue SPA):
  ```bash
  cd frontend/tft-builder
  npm install
  npm run dev # http://localhost:5173
  ```
- Open `http://localhost:5173`. The SPA calls the API at `http://localhost:3000/api`.
- Optional env:
  - Backend: `FRONTEND_ORIGINS=http://localhost:5173` (CORS).
  - Frontend: create `frontend/tft-builder/.env` with `VITE_API_BASE_URL=http://localhost:3000/api`.

## How To Deploy To Heroku (Rails API)
Deploy the Rails API; host the SPA separately (e.g., Netlify/Vercel) and point it to the Heroku API.

1) Create the app and Postgres
```bash
heroku login
heroku create tft-smartcomp-api --stack=heroku-22
heroku addons:create heroku-postgresql:mini -a tft-smartcomp-api
```

2) Configure environment
```bash
# Required if using Rails credentials
heroku config:set RAILS_MASTER_KEY=... -a tft-smartcomp-api

# CORS: set your production frontend origin(s)
heroku config:set FRONTEND_ORIGINS=https://frontend.tftcompapi.com -a tft-smartcomp-api

# Optional
heroku config:set RAILS_LOG_TO_STDOUT=enabled RACK_ENV=production RAILS_ENV=production -a tft-smartcomp-api
```

3) Push from repo (using git subtree)
```bash
# From the repo root
git subtree push --prefix ruby_backend/tft_team_builder heroku main
```

4) Run migrations (and optional seed)
```bash
heroku run rails db:migrate -a tft-smartcomp-api
heroku run rails db:seed -a tft-smartcomp-api # optional
```

5) Point the SPA to Heroku
- Set `VITE_API_BASE_URL=https://tft-smartcomp-api.herokuapp.com/api` in the frontend’s environment and deploy your SPA.

---

## Authors
- Ruitao Zhou (backend)
- Youran Ma (frontend)

## Purpose & Problem Statement
- A Teamfight Tactics (TFT) roster and composition builder with recommendations.
- Ships curated comps, champion/trait data, and a recommender that suggests best-fit comps given selected champions.

## MVP Structure
- Backend (Rails 8 API): JSON endpoints for champions, team comps (CRUD), and recommendations; JWT auth; absolute asset URLs; concise serializers.
- Frontend (Vue 3 + Vite SPA): search and recommendation views, comp list/detail, comp editor, login/profile management.
- Database (PostgreSQL): users, champions, traits, team comps; stores win/play rates, notes and source.

## Changelog (Brief)
- Implemented team comp CRUD and recommendation endpoint.
- Unified serializer output (e.g., `winRate`, `playRate`, `cards`) and absolute image/sprite URLs.
- Added JWT auth and role-based permissions (user/admin).

## Database Schema (Core Fields)

### users
| Column          | Type     | Constraints/Notes                   |
|-----------------|----------|-------------------------------------|
| id              | integer  | primary key                         |
| email           | string   | not null, unique index              |
| password_digest | string   | not null                            |
| role            | string   | not null, default `user`, indexed   |
| display_name    | string   |                                     |
| bio             | text     |                                     |
| location        | string   |                                     |
| avatar_url      | string   |                                     |
| created_at      | datetime |                                     |
| updated_at      | datetime |                                     |

### champions
| Column      | Type    | Constraints/Notes                         |
|-------------|---------|-------------------------------------------|
| id          | integer | primary key                               |
| name        | string  |                                           |
| tier        | integer |                                           |
| traits      | string  | e.g. "Bruiser / Void" (slash-delimited)   |
| image_url   | string  | relative or absolute; served as absolute  |
| sprite_name | string  | sprite sheet name                         |
| sprite_x    | integer |                                           |
| sprite_y    | integer |                                           |
| sprite_w    | integer |                                           |
| sprite_h    | integer |                                           |
| created_at  | datetime|                                           |
| updated_at  | datetime|                                           |

### traits
| Column       | Type    | Constraints/Notes |
|--------------|---------|-------------------|
| id           | integer | primary key       |
| api_id       | string  |                   |
| name         | string  |                   |
| image_full   | string  |                   |
| image_sprite | string  |                   |
| image_x      | integer |                   |
| image_y      | integer |                   |
| image_w      | integer |                   |
| image_h      | integer |                   |
| created_at   | datetime|                   |
| updated_at   | datetime|                   |

### team_comps
| Column      | Type     | Constraints/Notes                                 |
|-------------|----------|---------------------------------------------------|
| id          | integer  | primary key                                       |
| name        | string   | not null                                          |
| description | text     |                                                   |
| champions   | string   | comma-separated champion names                    |
| win_rate    | decimal  | precision:5, scale:4 (0.0000–1.0000), indexed     |
| play_rate   | decimal  | precision:5, scale:4 (0.0000–1.0000), indexed     |
| notes       | text     |                                                   |
| source      | string   |                                                   |
| created_at  | datetime |                                                   |
| updated_at  | datetime |                                                   |

> Source of truth: `ruby_backend/tft_team_builder/db/schema.rb`.

## API Endpoints (Concise)
- Auth & Profile
  - POST `/api/auth/register` — body `user:{ email, password, password_confirmation, display_name?, bio?, location?, avatar_url? }` — returns `{ token, user }`.
  - POST `/api/auth/login` — body `user:{ email, password }` — returns `{ token, user }`.
  - GET `/api/auth/me` — returns `{ user }` (requires `Authorization: Bearer <token>`).
  - GET `/api/profile` — returns `{ user }` (requires auth).
  - PATCH `/api/profile` — body `user:{ display_name?, bio?, location?, avatar_url?, password?, password_confirmation? }` — returns `{ user }` (requires auth).
- Champions
  - GET `/api/champions` — returns `[ { id, name, tier, traits[], imageUrl, sprite{ sheet,x,y,w,h } } ]`.
  - GET `/api/champions/:id` — returns one champion; 404 if not found.
- Team Comps (admin can update/delete; any authenticated user can create)
  - GET `/api/team_comps?limit=50&include_cards=true` — returns list of comps with `championNames[]` and optional `cards[]`.
  - GET `/api/team_comps/:id` — returns one comp.
  - POST `/api/team_comps` — body `team_comp:{ name, description?, notes?, source?, win_rate?, play_rate?, champion_ids?[], champion_names?[], champions?[] }`.
    - Server merges/normalizes names into `champions` and accepts rates as `0–1` or percentages.
  - PATCH `/api/team_comps/:id` — same body; admin only.
  - DELETE `/api/team_comps/:id` — admin only.
  - POST `/api/team_comps/recommendations` — body may include `include_cards`/`include_card_ids`/`includeCards`/`includeCardIds` (array of champion IDs); returns `{ requestedChampionIds, requestedChampionNames, teams:[ TeamComp + meta ] }` where `meta:{ matchCount, matchRatio, matchedChampionNames[], missingChampionNames[] }`.

Note: Use `Authorization: Bearer <token>` for protected endpoints. Response fields follow the serializers in the codebase.

## Roadmap
- Bug fix: adjust sprite picture cut and improve UI view.
- Data ingestion: hook into live/external data for dynamic comps and rates.
- Recommendation: add exclusions, trait weighting, patch filters.
- Quality: E2E tests (Playwright/Cypress) and fuller backend coverage.
- Personalization: drafts/favorites/ratings; sharing and comments.
