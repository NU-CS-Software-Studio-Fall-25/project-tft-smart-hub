#!/bin/bash

# TFT Smart Hub - Stop Development Servers

echo "🛑 Stopping TFT Smart Hub Development Servers..."
echo ""

# Check if processes are running
PUMA_RUNNING=$(pgrep -f puma)
VITE_RUNNING=$(pgrep -f vite)

if [ -z "$PUMA_RUNNING" ] && [ -z "$VITE_RUNNING" ]; then
    echo "ℹ️  No development servers are running"
    exit 0
fi

# Stop Rails (Puma)
if [ -n "$PUMA_RUNNING" ]; then
    echo "Stopping Rails backend (PID: $PUMA_RUNNING)..."
    pkill -f puma
    sleep 1
    if pgrep -f puma > /dev/null; then
        echo "⚠️  Force stopping Rails..."
        pkill -9 -f puma
    fi
    echo "✅ Rails backend stopped"
else
    echo "ℹ️  Rails backend not running"
fi

# Stop Vite
if [ -n "$VITE_RUNNING" ]; then
    echo "Stopping Vue frontend (PID: $VITE_RUNNING)..."
    pkill -f vite
    sleep 1
    if pgrep -f vite > /dev/null; then
        echo "⚠️  Force stopping Vite..."
        pkill -9 -f vite
    fi
    echo "✅ Vue frontend stopped"
else
    echo "ℹ️  Vue frontend not running"
fi

# Final verification
sleep 1
if pgrep -f "puma|vite" > /dev/null; then
    echo ""
    echo "⚠️  Warning: Some processes may still be running"
    echo "Run: ps aux | grep -E 'puma|vite' | grep -v grep"
else
    echo ""
    echo "✨ All servers stopped successfully!"
fi
