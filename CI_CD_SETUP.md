# 🛡️ GitHub CI/CD 和 Main 分支保护配置

## 📋 概述

本项目已配置完整的 CI/CD 流程和 Main 分支保护规则。所有代码变更必须通过自动化测试才能合并到 Main 分支。

---

## 🚀 GitHub Actions CI 工作流

### ✅ 已配置的工作流

位置：`.github/workflows/`

#### 1. **ci.yml** - 完整的 CI 管道
```
触发条件：push 到 main/develop 或 PR 到 main/develop

运行步骤：
├── 后端测试（Backend Tests）
│   ├── RSpec 单元测试
│   ├── 数据库迁移验证
│   └── PostgreSQL 服务
├── 代码质量检查（Code Quality）
│   ├── RuboCop 代码风格检查
│   └── Brakeman 安全扫描
├── 前端构建（Frontend Build）
│   ├── 依赖安装
│   ├── 构建验证
│   └── 构件上传
└── 集成测试（Integration Tests）
    └── Cucumber 功能测试
```

#### 2. **ci-backend.yml** - 专用后端工作流
- RSpec 测试
- RuboCop 代码检查
- Brakeman 安全扫描

#### 3. **ci-frontend.yml** - 专用前端工作流
- 依赖安装
- 构建验证
- ESLint 检查（如已配置）
- 单元测试（如已配置）

---

## 🔧 Main 分支保护配置

### 手动配置步骤

#### 1. 打开 Repository Settings

1. 进入 GitHub 项目首页
2. 点击 **Settings** 选项卡
3. 左侧菜单选择 **Branches**
4. 找到 **Branch protection rules** 部分
5. 点击 **Add rule**

#### 2. 创建保护规则

填写以下信息：

```
Branch name pattern: main
```

#### 3. 启用保护选项

✅ **Require a pull request before merging**
   - ✓ Require approvals: 1 个或更多审核者

✅ **Require status checks to pass before merging**
   - ✓ Require branches to be up to date before merging
   - ✓ CI - Full Test Suite (ci.yml)
   - ✓ CI - Backend Tests (ci-backend.yml 或 Backend - RSpec Tests)
   - ✓ CI - Frontend Build (ci-frontend.yml 或 Frontend - Build & Lint)

✅ **Require code reviews before merging**
   - Dismiss stale pull request approvals when new commits are pushed: ✓

✅ **Include administrators**
   - ✓ Enforce all of the above rules for administrators

#### 4. 保存规则

点击 **Create** 按钮完成配置

---

## 📊 CI/CD 工作流详解

### 后端测试流程

```yaml
RSpec Tests (Backend):
  ├── 启动 PostgreSQL 服务
  ├── 创建测试数据库
  ├── 运行 bundle install
  ├── 运行 rails db:migrate
  ├── 执行 RSpec 测试
  └── 上传测试结果

代码检查 (Code Quality):
  ├── RuboCop: 代码风格
  ├── Brakeman: 安全漏洞扫描
  └── 生成报告
```

### 前端构建流程

```yaml
Frontend Build:
  ├── 安装 Node 18
  ├── npm ci (安装依赖)
  ├── npm run build
  ├── 验证构建成功
  └── 上传构件
```

### 集成测试

```yaml
Cucumber Tests:
  ├── 等待后端和前端都通过
  ├── 运行 Cucumber 功能测试
  └── 验证端到端流程
```

---

## 🎯 工作流触发条件

### 自动触发场景

| 事件 | 分支 | 触发工作流 |
|------|------|-----------|
| push | main | ci.yml |
| push | develop | ci.yml |
| pull request | main | ci.yml |
| pull request | develop | ci.yml |
| path: ruby_backend/** | any | ci-backend.yml |
| path: frontend/** | any | ci-frontend.yml |

### 手动触发

可以在 GitHub Actions 页面手动运行工作流。

---

## 📋 PR 审核检查清单

当有新的 Pull Request 时，系统会自动检查：

### ✅ 必须通过的检查

- [ ] **CI - Full Test Suite** - 所有测试通过
  - [ ] RSpec Tests 通过
  - [ ] Code Quality 检查通过
  - [ ] Frontend Build 成功
  - [ ] Cucumber Tests 通过（可选）

- [ ] **Require status checks to pass**
  - 显示为 ✓（绿色）

- [ ] **Require code reviews**
  - 至少 1 个审核者批准

- [ ] **Require branches to be up to date**
  - 与 main 分支最新代码同步

### 🚫 阻止合并的情况

任何以下情况会阻止合并：

1. ❌ 测试失败
2. ❌ 代码质量检查失败
3. ❌ 构建失败
4. ❌ 未获得审核批准
5. ❌ 分支不是最新的

---

## 🔐 分支保护规则示意图

```
开发者创建 PR
    ↓
GitHub Actions 自动运行测试
    ├─ 后端测试 ✓
    ├─ 代码检查 ✓
    ├─ 前端构建 ✓
    └─ 集成测试 ✓
    ↓
所有检查通过 ✓
    ↓
代码审核 (1+ 批准) ✓
    ↓
分支是最新的 ✓
    ↓
✅ 允许合并到 Main
    ↓
自动部署到生产环境（可选）
```

---

## 🧪 测试详解

### RSpec 测试

```bash
# 运行位置
ruby_backend/tft_team_builder/

# 测试文件
spec/models/
├── user_spec.rb (9 个测试)
├── team_comp_spec.rb (20 个测试)
└── ...

# 总计：29+ 个单元测试
```

### RuboCop 检查

```bash
# 运行位置
ruby_backend/tft_team_builder/

# 检查内容
- 代码格式化
- 命名约定
- 复杂度指标
- 安全问题
```

### Brakeman 安全扫描

```bash
# 运行位置
ruby_backend/tft_team_builder/

# 检查内容
- SQL 注入漏洞
- XSS 漏洞
- 不安全的依赖
- Rails 安全问题
```

### Cucumber 集成测试

```bash
# 运行位置
ruby_backend/tft_team_builder/

# 功能场景
- 用户认证
- 团队管理
- 数据查询
- API 端点

# 总计：19+ 个场景
```

---

## 📊 CI 状态标识

| 状态 | 含义 | 颜色 |
|------|------|------|
| ✓ Passing | 所有检查通过 | 🟢 绿色 |
| ✗ Failing | 至少一个检查失败 | 🔴 红色 |
| ⊘ Skipped | 工作流被跳过 | ⚪ 灰色 |
| ⧗ In progress | 工作流运行中 | 🟡 黄色 |

---

## 💡 常见问题

### Q: 为什么 PR 不能合并？

A: 检查以下几点：
1. 是否所有 GitHub Actions 都通过了？
2. 是否有至少 1 个批准的审核？
3. 分支是否与 main 同步？

### Q: 如何重新运行失败的测试？

A: 在 PR 或 Actions 页面点击 "Re-run" 按钮

### Q: 可以跳过某个检查吗？

A: 不可以。如果有紧急情况，需要：
1. 联系仓库管理员
2. 修改分支保护规则（需要 admin 权限）

### Q: 如何本地运行相同的测试？

A: 
```bash
# 后端测试
cd ruby_backend/tft_team_builder
PG_USERNAME=test_user PG_PASSWORD=test_password bundle exec rspec

# 前端构建
cd frontend/tft-builder
npm run build
```

---

## 🔄 持续改进

### 定期审查

建议每 2 周审查一次：
- [ ] CI 通过率
- [ ] 测试覆盖率
- [ ] 代码质量指标
- [ ] 安全扫描结果

### 优化建议

- 增加前端单元测试
- 添加性能基准测试
- 配置自动部署到测试环境
- 添加代码覆盖率报告

---

## 📞 支持和资源

### GitHub Actions 文档
- [GitHub Actions 官方文档](https://docs.github.com/en/actions)
- [Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [Status Checks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-review/about-status-checks)

### 项目测试文档
- RSpec: [TEST_COVERAGE_SUMMARY.md](../TEST_COVERAGE_SUMMARY.md)
- Cucumber: [FEATURES.md](../FEATURES.md)
- 文档: [DOCS_COMPLETED.md](../DOCS_COMPLETED.md)

---

**最后更新**: 2025-12-06  
**维护者**: DevOps 团队
