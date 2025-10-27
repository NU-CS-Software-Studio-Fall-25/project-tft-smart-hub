#!/bin/bash

# TFT Smart Hub - Heroku 部署脚本
# 此脚本会构建前端并将其与后端一起部署到 Heroku

set -e  # 遇到错误立即退出

echo "🚀 开始部署到 Heroku..."

# 1. 构建前端
echo ""
echo "📦 步骤 1: 构建前端..."
cd frontend/tft-builder
echo "设置环境变量..."
export VITE_API_BASE_URL=https://tft-smartcomp-b3f1e37435eb.herokuapp.com/api
export VITE_USE_MOCK=false

echo "安装依赖..."
npm install

echo "构建生产版本..."
npm run build

# 2. 复制构建文件到 Rails public 目录
echo ""
echo "📋 步骤 2: 复制前端构建文件到 Rails public 目录..."
cd ../..
rm -rf ruby_backend/tft_team_builder/public/assets
rm -f ruby_backend/tft_team_builder/public/index.html
cp -r frontend/tft-builder/dist/* ruby_backend/tft_team_builder/public/

echo "✅ 前端文件已复制到: ruby_backend/tft_team_builder/public/"

# 3. 更新 Rails 路由以服务 SPA
echo ""
echo "📝 步骤 3: 确保 Rails 配置正确..."
# Rails 会自动服务 public 目录中的静态文件

# 4. 提交更改
echo ""
echo "💾 步骤 4: 提交更改到 Git..."
git add ruby_backend/tft_team_builder/public/
git commit -m "Add built frontend for Heroku deployment" || echo "没有新的更改需要提交"

# 5. 部署到 Heroku
echo ""
echo "🚢 步骤 5: 部署到 Heroku..."
git push heroku $(git subtree split --prefix ruby_backend/tft_team_builder main):main --force

echo ""
echo "✨ 部署完成！"
echo ""
echo "📱 应用地址: https://tft-smartcomp-b3f1e37435eb.herokuapp.com/"
echo ""
echo "⚠️  注意: 如果页面显示不正确，请检查浏览器控制台的错误信息"
