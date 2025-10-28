# TFT Smart Hub - 本地开发环境搭建指南

> 如果你从 GitHub 克隆了这个项目，按照以下步骤在本地运行

---

## 📋 前置要求

在开始之前，请确保你的系统已安装以下软件：

| 软件 | 版本要求 | 检查命令 | 安装链接 |
|------|---------|---------|---------|
| **Ruby** | 3.3.4+ | `ruby -v` | [ruby-lang.org](https://www.ruby-lang.org/) |
| **Node.js** | 20.15+ | `node -v` | [nodejs.org](https://nodejs.org/) |
| **PostgreSQL** | 12+ | `psql --version` | [postgresql.org](https://www.postgresql.org/) |
| **Git** | 任意版本 | `git --version` | [git-scm.com](https://git-scm.com/) |

---

## 🚀 快速开始（5 分钟）

### **1. 克隆项目**

```bash
# 克隆仓库
git clone https://github.com/NU-CS-Software-Studio-Fall-25/project-tft-smart-hub.git

# 进入项目目录
cd project-tft-smart-hub
```

---

### **2. 后端设置**

```bash
# 进入后端目录
cd ruby_backend/tft_team_builder

# 安装 Ruby 依赖
bundle install

# 创建数据库
rails db:create

# 运行数据库迁移
rails db:migrate

# 导入种子数据（英雄、特性、队伍数据）
rails db:seed

# 返回项目根目录
cd ../..
```

**可能遇到的问题：**

- **问题**: `bundle: command not found`  
  **解决**: 安装 bundler: `gem install bundler`

- **问题**: `pg gem` 安装失败  
  **解决**: 安装 PostgreSQL 开发库
  ```bash
  # Ubuntu/Debian
  sudo apt-get install libpq-dev
  
  # macOS
  brew install postgresql
  ```

- **问题**: 数据库连接错误  
  **解决**: 确保 PostgreSQL 服务正在运行
  ```bash
  # Ubuntu/Debian
  sudo service postgresql start
  
  # macOS
  brew services start postgresql
  ```

---

### **3. 前端设置**

```bash
# 进入前端目录
cd frontend/tft-builder

# 安装 npm 依赖
npm install

# 创建环境变量文件
echo "VITE_API_BASE_URL=http://localhost:3000/api
VITE_USE_MOCK=false" > .env

# 返回项目根目录
cd ../..
```

**可能遇到的问题：**

- **问题**: `npm: command not found`  
  **解决**: 安装 Node.js 和 npm

- **问题**: 依赖安装失败  
  **解决**: 清理缓存重试
  ```bash
  npm cache clean --force
  npm install
  ```

---

### **4. 启动服务**

#### **方式 1: 使用启动脚本（最简单）**

```bash
# 确保脚本有执行权限
chmod +x start-dev.sh stop-dev.sh

# 启动所有服务
./start-dev.sh

# 停止所有服务
./stop-dev.sh
```

#### **方式 2: 手动启动（推荐用于调试）**

**终端 1 - 启动后端:**
```bash
cd ruby_backend/tft_team_builder
bundle exec rails server
```

**终端 2 - 启动前端:**
```bash
cd frontend/tft-builder
npm run dev
```

**停止服务:** 在各终端按 `Ctrl + C`

---

### **5. 访问应用**

打开浏览器访问：
- **前端**: http://localhost:5173
- **后端 API**: http://localhost:3000/api/champions

---

## 🔍 验证安装

运行诊断脚本检查所有服务：

```bash
# 给脚本执行权限（首次）
chmod +x diagnose.sh

# 运行诊断
./diagnose.sh
```

应该看到：
```
✅ Rails backend running
✅ Vue frontend running
✅ Port 3000 (backend) is accessible
✅ Port 5173 (frontend) is accessible
✅ API responding (HTTP 200)
✅ Returned 64 champions
✅ Database has 64 champions
```

---

## 📁 项目结构

```
project-tft-smart-hub/
├── frontend/tft-builder/          # Vue.js 前端
│   ├── src/                       # 源代码
│   │   ├── components/            # 组件
│   │   ├── pages/                 # 页面
│   │   ├── router/                # 路由
│   │   ├── stores/                # 状态管理
│   │   └── services/              # API 服务
│   ├── .env                       # 环境变量（需要创建）
│   └── package.json               # npm 依赖
│
├── ruby_backend/tft_team_builder/ # Rails 后端
│   ├── app/                       # 应用代码
│   │   ├── controllers/           # 控制器
│   │   ├── models/                # 数据模型
│   │   └── serializers/           # API 序列化
│   ├── config/                    # 配置
│   │   ├── database.yml           # 数据库配置
│   │   ├── routes.rb              # 路由
│   │   └── initializers/cors.rb  # CORS 配置
│   ├── db/                        # 数据库
│   │   ├── migrate/               # 迁移文件
│   │   └── seeds.rb               # 种子数据
│   └── Gemfile                    # Ruby 依赖
│
├── start-dev.sh                   # 启动脚本
├── stop-dev.sh                    # 停止脚本
├── diagnose.sh                    # 诊断脚本
└── LOCAL_SETUP.md                 # 本文档
```

---

## 🛠️ 常用命令

### **查看日志**

```bash
# 后端日志
tail -f ruby_backend/tft_team_builder/log/development.log

# 前端日志（如果用脚本启动）
tail -f frontend/tft-builder/frontend.log
```

### **数据库操作**

```bash
cd ruby_backend/tft_team_builder

# 查看数据库状态
rails db:migrate:status

# 重置数据库（警告：会删除所有数据）
rails db:reset

# 进入 Rails 控制台
rails console

# 在控制台中：
Champion.count       # 查看英雄数量
User.all            # 查看所有用户
```

### **检查进程**

```bash
# 查看运行的服务
ps aux | grep -E "puma|vite" | grep -v grep

# 强制停止所有服务
pkill -f puma
pkill -f vite
```

### **端口检查**

```bash
# 检查端口占用
lsof -i :3000   # 后端
lsof -i :5173   # 前端

# 释放被占用的端口
kill -9 <PID>
```

---

## 🐛 常见问题排查

### **问题 1: 浏览器看不到数据**

**原因**: CORS 跨域问题或 API 连接失败

**解决方案**:
```bash
# 1. 确保使用 localhost 而不是 127.0.0.1
# 访问: http://localhost:5173 ✅
# 不要访问: http://127.0.0.1:5173 ❌（虽然现在也支持）

# 2. 检查后端是否返回数据
curl http://localhost:3000/api/champions

# 3. 查看浏览器控制台错误（F12 > Console 标签）

# 4. 清除浏览器缓存后刷新
# Windows/Linux: Ctrl + Shift + R
# Mac: Cmd + Shift + R
```

---

### **问题 2: 端口已被占用**

**错误信息**: `Address already in use - bind(2) for "127.0.0.1" port 3000`

**解决方案**:
```bash
# 查找占用端口的进程
lsof -i :3000

# 停止该进程
kill -9 <PID>

# 或使用停止脚本
./stop-dev.sh
```

---

### **问题 3: 数据库连接错误**

**错误信息**: `could not connect to server: Connection refused` 或 `Peer authentication failed`

**解决方案**:

**情况 1: PostgreSQL 服务未启动**
```bash
# 启动 PostgreSQL 服务
# Ubuntu/Debian
sudo service postgresql start

# macOS
brew services start postgresql

# Windows
# 从服务管理器启动 PostgreSQL 服务
```

**情况 2: 数据库配置错误（Peer authentication failed）**

如果看到 `Peer authentication failed for user "myr"` 或类似错误，说明 `database.yml` 配置不正确。

检查 `ruby_backend/tft_team_builder/config/database.yml` 文件：

```yaml
# 正确的本地开发配置（不需要用户名和密码）
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: tft_team_builder_development
```

**不要在 development 环境中添加 `username` 和 `password` 字段**，PostgreSQL 在本地使用 peer 认证。

修复后重启服务：
```bash
./stop-dev.sh
./start-dev.sh
```

---

### **问题 4: Ruby 版本不匹配**

**错误信息**: `Your Ruby version is X.X.X, but your Gemfile specified 3.3.4`

**解决方案**:
```bash
# 使用 rbenv 或 rvm 安装正确版本
# rbenv:
rbenv install 3.3.4
rbenv local 3.3.4

# rvm:
rvm install 3.3.4
rvm use 3.3.4
```

---

### **问题 5: npm 依赖安装失败**

**解决方案**:
```bash
cd frontend/tft-builder

# 删除旧依赖
rm -rf node_modules package-lock.json

# 清理缓存
npm cache clean --force

# 重新安装
npm install
```

---

## 🔐 默认测试账号

数据库种子数据包含以下测试账号：

| 角色 | 邮箱 | 密码 |
|------|------|------|
| 管理员 | admin@example.com | Admin123! |
| 普通用户 | player@example.com | Player123! |

---

## 💡 开发提示

### **推荐的开发工具**

- **IDE**: VS Code
- **浏览器**: Chrome 或 Firefox (带开发者工具)
- **API 测试**: Postman 或浏览器开发者工具
- **数据库管理**: pgAdmin 或 DBeaver

### **VS Code 扩展推荐**

```json
{
  "recommendations": [
    "rebornix.ruby",
    "vue.volar",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss"
  ]
}
```

### **代码风格**

- 前端: ESLint + Prettier
- 后端: RuboCop

```bash
# 检查代码风格
cd frontend/tft-builder
npm run lint

cd ruby_backend/tft_team_builder
rubocop
```

---

## 📚 技术栈

### **前端**
- Vue 3 (Composition API)
- Vite (构建工具)
- Vue Router (路由)
- Pinia (状态管理)
- Axios (HTTP 客户端)
- Bootstrap 5 (UI 框架)

### **后端**
- Ruby 3.3.4
- Rails 8.0.3 (API 模式)
- PostgreSQL (数据库)
- Puma (Web 服务器)
- JWT (认证)
- Rack-CORS (跨域)

---

## 🤝 获取帮助

### **文档**
- [Vue.js 官方文档](https://vuejs.org/)
- [Rails 官方指南](https://guides.rubyonrails.org/)
- [项目 README](./README.md)

### **问题排查流程**
1. 查看错误信息
2. 运行 `./diagnose.sh` 诊断
3. 检查日志文件
4. 搜索类似问题
5. 联系项目维护者

---

## ✅ 成功标志

如果看到以下内容，说明环境搭建成功：

1. ✅ 访问 http://localhost:5173 看到主页
2. ✅ 页面显示英雄卡片和队伍数据
3. ✅ 可以点击"Start Searching"进入搜索页面
4. ✅ 可以查看队伍列表和详情
5. ✅ 可以登录/注册账号

---

**最后更新**: 2025-10-27  
**维护者**: TFT Smart Hub Team

🎉 祝你开发愉快！如有问题，请查看上面的故障排查部分或联系团队。
