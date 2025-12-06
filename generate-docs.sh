#!/bin/bash

# Documentation Generator Script
# Generates comprehensive API documentation using YARD

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="${PROJECT_ROOT}/ruby_backend/tft_team_builder"
DOC_OUTPUT_DIR="${BACKEND_DIR}/doc"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "🔍 Documentation Generator (YARD)"
echo "=================================="
echo "Project: TFT Smart Hub"
echo "Timestamp: ${TIMESTAMP}"
echo "Output: ${DOC_OUTPUT_DIR}"
echo ""

# Clean old documentation
if [ -d "${DOC_OUTPUT_DIR}" ]; then
    echo "🗑️  Cleaning old documentation..."
    rm -rf "${DOC_OUTPUT_DIR}"
fi

# Generate documentation
echo "📚 Generating YARD documentation..."
cd "${BACKEND_DIR}"

if command -v yard &> /dev/null; then
    bundle exec yard doc
else
    echo "⚠️  Installing YARD and dependencies..."
    bundle install
    bundle exec yard doc
fi

echo ""
echo "✅ Documentation generated successfully!"
echo ""
echo "📖 Documentation location:"
echo "   ${DOC_OUTPUT_DIR}/index.html"
echo ""
echo "🌐 To view documentation:"
echo ""
echo "  Option 1 - Open HTML file:"
echo "    open ${DOC_OUTPUT_DIR}/index.html"
echo ""
echo "  Option 2 - Live server:"
echo "    cd ${BACKEND_DIR}"
echo "    yard server"
echo "    # Then visit http://localhost:8808"
echo ""
echo "📄 Documentation includes:"
echo "   ✓ Models: User, TeamComp, Champion, Comment, Like, Favorite"
echo "   ✓ Controllers: API endpoints with full documentation"
echo "   ✓ Services: Business logic utilities"
echo "   ✓ Helpers: View and API helpers"
echo ""
