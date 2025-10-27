# Heroku 部署文档

## 部署概览

本项目已成功部署到 Heroku！

**应用 URL:** https://tft-smartcomp-b3f1e37435eb.herokuapp.com/

**API 基础 URL:** https://tft-smartcomp-b3f1e37435eb.herokuapp.com/api

## 部署配置

### 1. Heroku 应用信息
- **应用名称:** tft-smartcomp
- **Stack:** heroku-24
- **Region:** us
- **Ruby 版本:** 3.3.4
- **Rails 版本:** 8.0.3

### 2. 数据库
- **类型:** PostgreSQL (heroku-postgresql:essential-0)
- **状态:** ✅ 已迁移和初始化
- **数据:** 
  - 128 个英雄 (Champions)
  - 52 个特质 (Traits)
  - 271 个阵容 (Team Comps)
  - 2 个用户账户（包括管理员）

### 3. 环境变量
已配置的环境变量：
- `DATABASE_URL` - PostgreSQL 数据库连接
- `SECRET_KEY_BASE` - Rails 密钥
- `RAILS_ENV=production`

## 部署步骤记录

### 修复的问题

1. **平台支持问题**
   - 添加了 Linux 平台支持到 Gemfile.lock
   - 命令: `bundle lock --add-platform x86_64-linux`

2. **Ruby 版本规范**
   - 在 Gemfile 中指定了 Ruby 版本 3.3.4
   
3. **Buildpack 配置**
   - 清除了多余的 Node.js buildpack
   - 只保留了 Ruby buildpack

4. **Zeitwerk 自动加载问题**
   - 修复了 `TftDataImporter` 的模块命名空间
   - 从 `Importers::TftDataImporter` 改为 `Services::Importers::TftDataImporter`
   - 更新了相关引用文件：
     - `lib/services/importers/tft_data_importer.rb`
     - `lib/tasks/tft_data_import.rake`
     - `db/seeds.rb`

## 如何更新部署

### 1. 提交代码更改
```bash
git add .
git commit -m "你的提交信息"
```

### 2. 部署到 Heroku
由于后端代码在子目录中，使用 git subtree 进行部署：

```bash
git push heroku `git subtree split --prefix ruby_backend/tft_team_builder main`:main --force
```

### 3. 运行数据库迁移（如果需要）
```bash
heroku run rails db:migrate -a tft-smartcomp
```

### 4. 运行 seed（如果需要重新初始化数据）
```bash
heroku run rails db:seed -a tft-smartcomp
```

## API 端点测试

### 测试 Champions 端点
```bash
curl https://tft-smartcomp-b3f1e37435eb.herokuapp.com/api/champions
```

### 测试 Team Comps 端点
```bash
curl https://tft-smartcomp-b3f1e37435eb.herokuapp.com/api/team_comps
```

### 测试 Traits 端点
```bash
curl https://tft-smartcomp-b3f1e37435eb.herokuapp.com/api/traits
```

## 常用 Heroku 命令

### 查看日志
```bash
heroku logs --tail -a tft-smartcomp
```

### 查看应用信息
```bash
heroku apps:info -a tft-smartcomp
```

### 重启应用
```bash
heroku restart -a tft-smartcomp
```

### 查看环境变量
```bash
heroku config -a tft-smartcomp
```

### 设置环境变量
```bash
heroku config:set VARIABLE_NAME=value -a tft-smartcomp
```

### 运行 Rails Console
```bash
heroku run rails console -a tft-smartcomp
```

## 前端部署建议

前端 Vue.js 应用建议单独部署到：
- **Netlify** (推荐)
- **Vercel**
- **GitHub Pages**

前端部署后，需要设置环境变量：
```
VITE_API_BASE_URL=https://tft-smartcomp-b3f1e37435eb.herokuapp.com/api
```

并确保后端 CORS 配置允许前端域名访问。

## 故障排查

### 应用崩溃
1. 查看日志：`heroku logs --tail -a tft-smartcomp`
2. 检查错误信息
3. 确认数据库连接正常

### 数据库问题
1. 检查迁移状态：`heroku run rails db:migrate:status -a tft-smartcomp`
2. 重新运行迁移：`heroku run rails db:migrate -a tft-smartcomp`

### 环境变量缺失
1. 检查配置：`heroku config -a tft-smartcomp`
2. 添加缺失的变量

## 维护注意事项

1. **定期备份数据库**
   ```bash
   heroku pg:backups:capture -a tft-smartcomp
   ```

2. **监控应用性能**
   - 使用 Heroku Dashboard 查看应用指标
   - 注意 dyno 使用情况

3. **更新依赖**
   - 定期更新 Ruby gems
   - 运行 `bundle update` 并测试

## 成功部署！

✅ Rails 后端已成功部署到 Heroku
✅ 数据库迁移完成
✅ 初始数据已导入
✅ API 端点正常工作

部署时间：2025-10-27
