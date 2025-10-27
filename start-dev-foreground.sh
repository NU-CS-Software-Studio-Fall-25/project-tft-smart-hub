#!/bin/bash

# TFT Smart Hub - Foreground Development Mode
# This script starts servers in foreground (you can see logs directly)
# Use Ctrl+C to stop

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 Starting TFT Smart Hub (Foreground Mode)"
echo ""
echo "⚠️  This will start both servers in the background, then show logs"
echo "⚠️  Press Ctrl+C to view stop menu"
echo ""

# Check and stop existing processes
if pgrep -f "puma" > /dev/null || pgrep -f "vite" > /dev/null; then
    echo "⚠️  Stopping existing processes..."
    pkill -f puma 2>/dev/null
    pkill -f vite 2>/dev/null
    sleep 2
fi

# Start backend in background
echo "📡 Starting Rails backend..."
cd "${PROJECT_ROOT}/ruby_backend/tft_team_builder"
bundle exec rails server > /dev/null 2>&1 &
BACKEND_PID=$!
echo "✅ Backend started (PID: ${BACKEND_PID})"

# Wait for backend to start
sleep 3

# Start frontend in background
echo "🎨 Starting Vue frontend..."
cd "${PROJECT_ROOT}/frontend/tft-builder"
VITE_API_BASE_URL=http://localhost:3000/api VITE_USE_MOCK=false npm run dev > /dev/null 2>&1 &
FRONTEND_PID=$!
echo "✅ Frontend started (PID: ${FRONTEND_PID})"

# Wait for frontend to start
sleep 3

echo ""
echo "✨ Servers are running!"
echo "   Backend:  http://localhost:3000"
echo "   Frontend: http://localhost:5173"
echo ""
echo "📊 Showing combined logs (Press Ctrl+C to stop)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🛑 Stopping servers..."
    pkill -f puma 2>/dev/null
    pkill -f vite 2>/dev/null
    sleep 1
    echo "✨ All servers stopped!"
    exit 0
}

trap cleanup INT TERM

# Show logs from both servers
tail -f "${PROJECT_ROOT}/ruby_backend/tft_team_builder/log/development.log" 2>/dev/null &
TAIL_PID=$!

# Keep script running
wait $TAIL_PID
