#!/bin/bash

# Documentation Generator Script
# Generates comprehensive API documentation using YARD

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOC_OUTPUT_DIR="${PROJECT_ROOT}/doc"
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
cd "${PROJECT_ROOT}"

bundle exec yard doc \
    --output-dir "${DOC_OUTPUT_DIR}" \
    --protected \
    --private \
    --exclude vendor,log,tmp,node_modules,public/assets,spec,test \
    app lib

echo ""
echo "✅ Documentation generated successfully!"
echo ""
echo "📖 Documentation location:"
echo "   ${DOC_OUTPUT_DIR}/index.html"
echo ""
echo "🌐 To view documentation, run:"
echo "   yard server"
echo "   # Then visit http://localhost:8808"
echo ""
echo "📄 Coverage:"
echo "   - Models: User, TeamComp, Champion, Comment, Like, Favorite"
echo "   - Controllers: API controllers with full endpoint documentation"
echo "   - Services: Business logic and utilities"
echo "   - Helpers: View and API helpers"
echo ""


