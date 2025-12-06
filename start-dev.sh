#!/bin/bash

# TFT Smart Hub - Local Development Startup Script

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 Starting TFT Smart Hub Development Servers..."
echo ""

# Check and stop existing processes
echo "🔍 Checking for existing processes..."
if pgrep -f "puma" > /dev/null || pgrep -f "vite" > /dev/null; then
    echo "⚠️  Found running processes, stopping them first..."
    pkill -f puma 2>/dev/null
    pkill -f vite 2>/dev/null
    sleep 2
    echo "✅ Old processes stopped"
else
    echo "✅ No existing processes found"
fi
echo ""

# Start backend
echo "📡 Starting Rails backend..."
cd "${PROJECT_ROOT}/ruby_backend/tft_team_builder"

# Set database environment variables
export PG_USERNAME=zrt
export PG_PASSWORD=postgres
export PG_HOST=localhost
export PG_PORT=5432

nohup bundle exec rails server > server.log 2>&1 &
BACKEND_PID=$!
echo "✅ Backend started (PID: ${BACKEND_PID})"
echo "   URL: http://localhost:3000"
echo "   Logs: ruby_backend/tft_team_builder/server.log"
echo ""

# Wait a moment for backend to start
sleep 2

# Start frontend
echo "🎨 Starting Vue frontend..."
cd "${PROJECT_ROOT}/frontend/tft-builder"

# Set frontend environment variables
export VITE_API_BASE_URL=http://localhost:3000/api
export VITE_USE_MOCK=false

nohup npm run dev > frontend.log 2>&1 &
FRONTEND_PID=$!
echo "✅ Frontend started (PID: ${FRONTEND_PID})"
echo "   URL: http://localhost:5173"
echo "   Logs: frontend/tft-builder/frontend.log"
echo ""

echo "✨ All servers started!"
echo ""
echo "🌐 Open in browser: http://localhost:5173"
echo ""
echo "📝 Quick commands:"
echo "   View backend logs:  tail -f ruby_backend/tft_team_builder/server.log"
echo "   View frontend logs: tail -f frontend/tft-builder/frontend.log"
echo "   Check processes:    ps aux | grep -E 'puma|vite' | grep -v grep"
echo "   Stop all:           ./stop-dev.sh"
echo ""
echo "⏳ Waiting for servers to fully start..."
sleep 3

# Verify servers are running
echo ""
echo "🔍 Verifying servers..."
if curl -s http://localhost:3000/up > /dev/null 2>&1; then
    echo "✅ Backend is running on http://localhost:3000"
else
    echo "⚠️  Backend may still be starting, check logs: tail -f ruby_backend/tft_team_builder/server.log"
fi

if curl -s http://localhost:5173 > /dev/null 2>&1; then
    echo "✅ Frontend is running on http://localhost:5173"
else
    echo "⚠️  Frontend may still be starting, check logs: tail -f frontend/tft-builder/frontend.log"
fi
echo ""
echo "✨ Ready! Open http://localhost:5173 in your browser"
echo ""
echo "🔧 Troubleshooting:"
echo "   If you see no data in browser:"
echo "   1. Open browser DevTools (F12) > Console tab"
echo "   2. Check for any red errors"
echo "   3. Open Network tab and look for API calls to localhost:3000"
echo "   4. Try: curl http://localhost:3000/api/champions"
echo ""
echo "   If problems persist, use foreground mode: ./start-dev-foreground.sh"
