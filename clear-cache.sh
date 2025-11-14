#!/bin/bash

# TFT Smart Hub - Complete Cache Clearing Script

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "🧹 Clearing all caches for TFT Smart Hub..."
echo ""

# Stop servers first
echo "🛑 Stopping development servers..."
"$PROJECT_ROOT/stop-dev.sh" 2>/dev/null
echo "✅ Servers stopped"
echo ""

# Clear Rails cache
echo "🔧 Clearing Rails cache..."
cd "${PROJECT_ROOT}/ruby_backend/tft_team_builder"
rm -rf tmp/cache tmp/sockets tmp/pids
rm -rf log/*
echo "✅ Rails cache cleared"
echo ""

# Clear frontend cache
echo "🎨 Clearing frontend cache..."
cd "${PROJECT_ROOT}/frontend/tft-builder"
rm -rf node_modules/.vite
npm cache clean --force 2>/dev/null
echo "✅ Frontend cache cleared"
echo ""

# Reinstall frontend dependencies
echo "📦 Reinstalling frontend dependencies..."
rm -rf node_modules package-lock.json
npm install > /dev/null 2>&1
echo "✅ Dependencies reinstalled"
echo ""

# Clear system temp files
echo "🗂️  Clearing system temp files..."
rm -rf "${PROJECT_ROOT}/ruby_backend/tft_team_builder/tmp/*"
echo "✅ Temp files cleared"
echo ""

echo "✨ All caches cleared successfully!"
echo ""
echo "💡 Browser cache clearing instructions:"
echo "   1. Open browser DevTools (F12)"
echo "   2. Go to Application/Storage tab"
echo "   3. Clear Storage > Clear site data"
echo "   4. Or run: clearTFTCache() in console"
echo ""
echo "🚀 Ready to start fresh development environment!"