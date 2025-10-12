# TFT Team Lab Monorepo

This project combines a Rails 8 JSON API with a Vue 3 + Vite single-page application to deliver a polished Teamfight Tactics (TFT) team builder. The backend exposes champion data, curated team compositions, and recommendation logic, while the frontend handles all presentation, navigation, and client-side interactions.

## Quick Start

```bash
# 1. Start the Rails API
cd ruby_backend/tft_team_builder
bundle install
bundle exec rails db:create db:migrate db:seed
bundle exec rails server

# 2. In another terminal, launch the Vue dev server
cd ../../frontend/tft-builder
npm install
npm run dev
```

Visit **http://localhost:5173** in your browser. The SPA proxies API calls to **http://localhost:3000/api**.

## Tech Stack
- **Backend:** Ruby on Rails 8.0 (API only), PostgreSQL, Rack CORS
- **Frontend:** Vue 3, Vite, Bootstrap 5, Bootstrap Icons, Axios
- **Testing & Tooling:** Rails test suite (Minitest), Vite build tooling, npm scripts

## Repository Layout
```
frontend/
  tft-builder/         # Vue SPA
ruby_backend/
  tft_team_builder/    # Rails API
```

## Prerequisites
- Ruby 3.4.x (3.3+ should work)
- Node.js 18+ (tested with Node 20)
- PostgreSQL 14+
- Yarn or npm (examples below use npm)

## Backend Setup (Rails API)
```bash
cd ruby_backend/tft_team_builder
bundle install

# Prepare the database
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed

# Run the test suite
bundle exec rails test

# Start the API (default on http://localhost:3000)
bundle exec rails server
```

### Useful Environment Variables
- `FRONTEND_ORIGINS` - comma separated list of origins allowed via CORS (default is `http://localhost:5173`).
- `DATABASE_URL` - optional PostgreSQL connection string when running outside local defaults.

## Frontend Setup (Vue SPA)
```bash
cd frontend/tft-builder
npm install

# Run unit build check (optional but recommended)
npm run build

# Start the Vite dev server (http://localhost:5173)
npm run dev
```

### Frontend Environment Variables
Create `frontend/tft-builder/.env` if you need custom configuration:
```
VITE_API_BASE_URL=http://localhost:3000/api
VITE_USE_MOCK=false
```

`VITE_USE_MOCK` toggles the mock data layer shipped with the original prototype. Leave it as `false` to use the Rails API.

## Running Everything Together
1. Start PostgreSQL locally.
2. Launch the Rails API (`bundle exec rails server`).
3. In another terminal, launch the Vite dev server (`npm run dev`).
4. Visit `http://localhost:5173` to use the app. The SPA calls the API on `http://localhost:3000/api`.

## Key Features
- Champion roster API with absolute image URLs, trait metadata, and sprite information.
- Team composition CRUD endpoints with win/play rate metadata, strategy notes, and source attribution.
- Recommendation engine that matches selected champions against stored team comps and returns ranked results with match analytics.
- Vue SPA with:
  - Home hero / navigation shell.
  - Champion synergy search page.
  - Recommendation results view.
  - Team library list/detail pages.
  - Team editor for creating or updating comps with full validation.
  - Right-click champion quick view modal with team usage breakdown.

## Data & Seeding
- Champion, trait, and example team composition data live under `ruby_backend/tft_team_builder/lib/tasks/data`.
- `bundle exec rails db:seed` loads champions/traits and three example team comps for local use.
- Champion art is bundled as sprite sheets under `frontend/tft-builder/public/sprites`. The SPA crops the correct frame using the `sprite` metadata returned by the API; no extra setup required after running the seed task.

## Testing
- **Rails:** `bundle exec rails test`
- **Frontend build check:** `npm run build`

## Next Steps / Ideas
1. Wire up live TFT data ingestion from the Python pipeline or an external source for dynamic comp updates.
2. Add authentication if you plan to persist user-specific drafts or ratings.
3. Extend the recommendation endpoint to support exclusion filters, trait weighting, or patch gating.
4. Add e2e tests (Playwright/Cypress) to cover critical flows in the SPA.

---

For legacy documentation about the original Rails UI scaffold, see `ruby_backend/tft_team_builder/README.md`. That app now operates purely as the API for the Vue SPA.
