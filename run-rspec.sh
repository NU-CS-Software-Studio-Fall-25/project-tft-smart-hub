#!/bin/bash

# RSpec 测试运行脚本

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="${PROJECT_ROOT}/ruby_backend/tft_team_builder"

echo "🧪 Running RSpec Tests"
echo ""

# 设置数据库环境变量
export PG_USERNAME=zrt
export PG_PASSWORD=postgres
export PG_HOST=localhost
export PG_PORT=5432

cd "$BACKEND_DIR"

# 显示运行测试的信息
echo "📊 Test Execution:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$1" = "coverage" ]; then
    # 生成覆盖率报告
    echo "📈 Running tests with coverage report..."
    bundle exec rspec --format html --out rspec_results.html
    echo ""
    echo "✅ Coverage report generated: rspec_results.html"
elif [ "$1" = "watch" ]; then
    # 监视模式
    echo "👀 Running in watch mode..."
    bundle exec rspec --pattern '**/*_spec.rb' --watch
else
    # 运行所有测试或特定测试
    if [ -z "$1" ]; then
        echo "🔄 Running all RSpec tests..."
        bundle exec rspec spec/
    else
        echo "🔄 Running: $1"
        bundle exec rspec "$1"
    fi
fi

echo ""
echo "✨ Done!"
