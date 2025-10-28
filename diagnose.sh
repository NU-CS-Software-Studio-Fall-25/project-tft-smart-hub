#!/bin/bash

# TFT Smart Hub - Diagnostic Script

echo "🔍 TFT Smart Hub Diagnostics"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if servers are running
echo "1️⃣  Checking processes..."
PUMA_PID=$(pgrep -f puma)
VITE_PID=$(pgrep -f vite)

if [ -n "$PUMA_PID" ]; then
    echo "   ✅ Rails backend running (PID: $PUMA_PID)"
else
    echo "   ❌ Rails backend NOT running"
fi

if [ -n "$VITE_PID" ]; then
    echo "   ✅ Vue frontend running (PID: $VITE_PID)"
else
    echo "   ❌ Vue frontend NOT running"
fi
echo ""

# Check ports
echo "2️⃣  Checking ports..."
if nc -z localhost 3000 2>/dev/null || curl -s http://localhost:3000/up > /dev/null 2>&1; then
    echo "   ✅ Port 3000 (backend) is accessible"
else
    echo "   ❌ Port 3000 (backend) is NOT accessible"
fi

if nc -z localhost 5173 2>/dev/null || curl -s http://localhost:5173 > /dev/null 2>&1; then
    echo "   ✅ Port 5173 (frontend) is accessible"
else
    echo "   ❌ Port 5173 (frontend) is NOT accessible"
fi
echo ""

# Test backend API
echo "3️⃣  Testing backend API..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/champions 2>/dev/null)
if [ "$RESPONSE" = "200" ]; then
    COUNT=$(curl -s http://localhost:3000/api/champions 2>/dev/null | grep -o '"id"' | wc -l)
    echo "   ✅ API responding (HTTP $RESPONSE)"
    echo "   ✅ Returned $COUNT champions"
else
    echo "   ❌ API not responding (HTTP $RESPONSE)"
fi
echo ""

# Check database
echo "4️⃣  Checking database..."
cd "$(dirname "$0")/ruby_backend/tft_team_builder"
DB_COUNT=$(rails runner "puts Champion.count" 2>/dev/null)
if [ -n "$DB_COUNT" ] && [ "$DB_COUNT" -gt 0 ]; then
    echo "   ✅ Database has $DB_COUNT champions"
else
    echo "   ❌ Database issue or no data"
fi
echo ""

# Check frontend config
echo "5️⃣  Checking frontend configuration..."
cd "$(dirname "$0")/frontend/tft-builder"
if [ -f ".env" ]; then
    echo "   📄 .env file contents:"
    cat .env | sed 's/^/      /'
else
    echo "   ⚠️  No .env file found"
fi
echo ""

# Check recent logs
echo "6️⃣  Recent backend errors (if any)..."
if [ -f "$(dirname "$0")/ruby_backend/tft_team_builder/log/development.log" ]; then
    ERRORS=$(tail -100 "$(dirname "$0")/ruby_backend/tft_team_builder/log/development.log" | grep -i "error" | tail -3)
    if [ -n "$ERRORS" ]; then
        echo "$ERRORS" | sed 's/^/   /'
    else
        echo "   ✅ No recent errors"
    fi
else
    echo "   ⚠️  Log file not found"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Next steps:"
if [ -z "$PUMA_PID" ] || [ -z "$VITE_PID" ]; then
    echo "   Run: ./start-dev.sh"
elif [ "$RESPONSE" != "200" ]; then
    echo "   Backend issue - check: tail -f ruby_backend/tft_team_builder/server.log"
else
    echo "   Open browser: http://localhost:5173"
    echo "   Open DevTools (F12) > Console tab to see any frontend errors"
    echo "   Check Network tab for failed API requests"
fi
echo ""
