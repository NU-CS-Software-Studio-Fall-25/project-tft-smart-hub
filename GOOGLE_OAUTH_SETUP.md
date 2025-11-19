# Google OAuth 配置指南

本应用已集成 Google OAuth 登录功能。以下是配置步骤：

## 1. 创建 Google Cloud 项目

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建新项目或选择现有项目
3. 项目名称建议：`TFT Team Lab`

## 2. 配置 OAuth 同意屏幕

1. 在左侧菜单选择：**APIs & Services** > **OAuth consent screen**
2. 选择用户类型：
   - **External**（外部）- 任何 Google 账号都可以登录
   - **Internal**（内部）- 仅限组织内部用户（需要 Google Workspace）
3. 填写应用信息：
   - **App name**: TFT Team Lab
   - **User support email**: 你的邮箱
   - **Developer contact email**: 你的邮箱
4. 授权域名（可选，部署后配置）：
   - 本地开发不需要
   - 生产环境：`tft-smartcomp-b3f1e37435eb.herokuapp.com`
5. 点击 **Save and Continue**
6. **Scopes**（权限范围）：
   - 添加 `email`
   - 添加 `profile`
   - 这些是默认的基本信息
7. 保存并继续

## 3. 创建 OAuth 2.0 客户端 ID

1. 在左侧菜单选择：**APIs & Services** > **Credentials**
2. 点击顶部 **+ CREATE CREDENTIALS** > **OAuth client ID**
3. 选择应用类型：**Web application**
4. 配置客户端：
   - **Name**: TFT Team Lab Web Client
   
   - **Authorized JavaScript origins**（已授权的 JavaScript 来源）：
     ```
     http://localhost:5173
     http://localhost:3000
     https://tft-smartcomp-b3f1e37435eb.herokuapp.com
     ```
   
   - **Authorized redirect URIs**（已授权的重定向 URI）：
     ```
     http://localhost:5173
     http://localhost:3000
     https://tft-smartcomp-b3f1e37435eb.herokuapp.com
     ```

5. 点击 **Create**
6. 会弹出对话框显示：
   - **Client ID**（客户端 ID）
   - **Client secret**（客户端密钥）
7. **复制 Client ID**（前端和后端都需要）

## 4. 配置本地开发环境

### 前端配置

编辑 `frontend/tft-builder/.env`：

```env
VITE_API_BASE_URL=http://localhost:3000/api
VITE_USE_MOCK=false
VITE_GOOGLE_CLIENT_ID=你的_GOOGLE_CLIENT_ID
```

**示例**：
```env
VITE_GOOGLE_CLIENT_ID=123456789-abcdefghijk.apps.googleusercontent.com
```

### 后端配置

编辑 `ruby_backend/tft_team_builder/.env`（创建文件如果不存在）：

```env
GOOGLE_CLIENT_ID=你的_GOOGLE_CLIENT_ID
```

## 5. 配置 Heroku 生产环境

设置环境变量：

```bash
heroku config:set GOOGLE_CLIENT_ID=你的_GOOGLE_CLIENT_ID --app tft-smartcomp
```

查看已设置的环境变量：

```bash
heroku config --app tft-smartcomp
```

## 6. 测试 Google 登录

### 本地测试

1. 启动后端服务器：
   ```bash
   cd ruby_backend/tft_team_builder
   rails server
   ```

2. 启动前端开发服务器：
   ```bash
   cd frontend/tft-builder
   npm run dev
   ```

3. 访问 http://localhost:5173/login
4. 应该能看到 "Sign in with Google" 按钮
5. 点击按钮测试 Google 登录流程

### 生产环境测试

部署到 Heroku 后：

1. 访问 https://tft-smartcomp-c2a2f4cb04ac.herokuapp.com/login
2. 测试 Google 登录功能

## 7. OAuth 用户特点

- OAuth 登录的用户**不需要密码**
- OAuth 用户的邮箱**自动验证**（Google 已验证）
- 用户数据存储在 `users` 表中，带有：
  - `provider: 'google'`
  - `uid: Google 用户 ID`
  - `email_verified_at: 创建时间`

## 8. 数据库迁移

在部署前需要运行迁移：

### 本地
```bash
cd ruby_backend/tft_team_builder
rails db:migrate
```

### Heroku
```bash
heroku run rails db:migrate --app tft-smartcomp
```

## 故障排除

### "Google Sign-In button not showing"
- 检查 `VITE_GOOGLE_CLIENT_ID` 是否已设置
- 检查浏览器控制台是否有错误
- 确认 Google Identity Services 脚本已加载（查看 `index.html`）

### "Invalid Google token"
- 确认后端 `GOOGLE_CLIENT_ID` 环境变量已设置
- 确认前后端使用相同的 Client ID
- 检查 Client ID 是否正确复制（无额外空格）

### "Redirect URI mismatch"
- 在 Google Cloud Console 中添加当前域名到已授权的 JavaScript 来源
- 添加 `/login` 路径到已授权的重定向 URI

### "Access blocked: TFT Team Lab hasn't completed Google verification"
- 这是正常现象，应用未发布前会显示此警告
- 点击 "Continue"（继续）或 "Advanced" > "Go to TFT Team Lab (unsafe)" 继续测试
- 发布应用需要 Google 审核（非必需，仅内部使用可忽略）

## 参考资源

- [Google Identity Services 文档](https://developers.google.com/identity/gsi/web/guides/overview)
- [OAuth 2.0 文档](https://developers.google.com/identity/protocols/oauth2)
- [Rails OAuth 最佳实践](https://github.com/oauth-xx/oauth2)
