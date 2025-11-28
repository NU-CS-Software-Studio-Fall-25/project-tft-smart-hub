#!/bin/bash

# TFT Smart Hub - Heroku Deployment Script
# Builds frontend and deploys full-stack app to Heroku

set -e  # Exit on error

# Allow overriding the Heroku app and host via environment variables.
# Defaults keep backward compatibility with the original course app.
HEROKU_APP="${HEROKU_APP:-tft-smartcomp}"
HEROKU_APP_HOST="${HEROKU_APP_HOST:-${HEROKU_APP}-b3f1e37435eb.herokuapp.com}"
HEROKU_GIT_URL="https://git.heroku.com/${HEROKU_APP}.git"
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 Starting Heroku deployment..."
echo ""

# Step 1: Build frontend
echo "📦 Step 1: Building frontend..."
cd "${PROJECT_ROOT}/frontend/tft-builder"

if [ ! -d "node_modules" ]; then
    echo "Installing npm dependencies..."
    npm install
fi

echo "Building production bundle..."
VITE_API_BASE_URL="https://${HEROKU_APP_HOST}/api" \
VITE_USE_MOCK=false \
npm run build

if [ ! -f "dist/index.html" ]; then
    echo "❌ Build failed: dist/index.html not found"
    exit 1
fi
echo "✅ Frontend built successfully"
echo ""

# Step 2: Copy assets to Rails public directory
echo "📋 Step 2: Copying frontend assets to Rails..."
cd "${PROJECT_ROOT}"

# Clean old assets (keep tft-champion, tft-trait folders and error pages)
find ruby_backend/tft_team_builder/public -maxdepth 1 -type f ! -name '404.html' ! -name '422.html' ! -name '500.html' ! -name 'robots.txt' -delete
rm -rf ruby_backend/tft_team_builder/public/assets

# Copy new build
cp -r frontend/tft-builder/dist/* ruby_backend/tft_team_builder/public/
echo "✅ Assets copied to ruby_backend/tft_team_builder/public/"
echo ""

# Step 3: Commit to GitHub (optional but recommended)
echo "💾 Step 3: Committing to GitHub..."
if [ "${SKIP_GITHUB_PUSH:-0}" = "1" ]; then
    echo "Skipping GitHub commit/push (SKIP_GITHUB_PUSH=1)"
else
    git add ruby_backend/tft_team_builder/public/
    if git diff --cached --quiet; then
        echo "No changes to commit"
    else
        git commit -m "Update frontend build for deployment"
        git push origin main
        echo "✅ Pushed to GitHub"
    fi
fi
echo ""

# Step 4: Deploy to Heroku using subdirectory push
echo "🚢 Step 4: Deploying to Heroku..."
cd "${PROJECT_ROOT}/ruby_backend/tft_team_builder"

# Remove any existing git repo in subdirectory
rm -rf .git

# Initialize temporary git repo
git init
git add .
git commit -m "Deploy to Heroku"

# Force push to Heroku
echo "Pushing to Heroku (this may take a few minutes)..."
git push "${HEROKU_GIT_URL}" HEAD:main --force

# Cleanup
rm -rf .git

cd "${PROJECT_ROOT}"
echo ""
echo "✅ Deployment complete!"
echo ""
echo "📱 App URL: https://${HEROKU_APP_HOST}/"
echo "📊 Logs: heroku logs --tail --app ${HEROKU_APP}"
echo ""
echo "💡 Tips:"
echo "   - Clear browser cache if UI doesn't update"
echo "   - Check console for any errors"
echo "   - Run 'heroku restart --app ${HEROKU_APP}' if needed"

