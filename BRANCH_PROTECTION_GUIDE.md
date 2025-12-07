# GitHub 分支保护配置指南 (Branch Protection)

## 🎯 目标
为 `main` 分支启用保护，确保所有代码改动都必须通过 CI/CD 测试和代码审查。

---

## 📝 配置步骤

### 第一步：打开 Settings

1. 在浏览器打开项目页面：
   ```
   https://github.com/NU-CS-Software-Studio-Fall-25/project-tft-smart-hub
   ```

2. 点击顶部的 **Settings** 选项卡
   
   ![Settings 位置](在顶部导航栏，在 "Pull requests" 右边)

---

### 第二步：找到 Branches 设置

1. 左侧菜单栏找到 **Code and automation** 部分
2. 点击 **Branches**
   
   ![Branches 路径](Settings → Code and automation → Branches)

---

### 第三步：添加分支保护规则

1. 找到 **Branch protection rules** 部分
2. 点击 **Add rule** 按钮

---

### 第四步：填写规则配置

#### 4.1 基本信息
在 **Branch name pattern** 字段输入：
```
main
```

#### 4.2 启用必需检查

勾选以下选项：

**1️⃣ Require a pull request before merging**
   - ✅ 勾选此项
   - 子选项：
     - ✅ **Require approvals** - 设置为 `1`
     - ✅ **Dismiss stale pull request approvals when new commits are pushed**
     - ✅ **Require review from Code Owners** (可选)

**2️⃣ Require status checks to pass before merging**
   - ✅ 勾选此项
   - ✅ **Require branches to be up to date before merging**
   - ✅ 选择以下状态检查：
     ```
     ✓ Backend - RSpec Tests
     ✓ Backend - Code Quality (RuboCop)
     ✓ Backend - Security (Brakeman)
     ✓ Frontend - Build & Lint
     ✓ Integration - Cucumber Tests
     ```

**3️⃣ 其他保护选项**
   - ✅ **Include administrators** - 管理员也需要遵守这些规则
   - ✅ **Restrict who can push to matching branches** (可选)
   - ✅ **Allow force pushes** - 不勾选（禁止强制推送）
   - ✅ **Allow deletions** - 不勾选（禁止删除分支）

---

### 第五步：保存配置

点击 **Create** 按钮创建规则

✅ 完成！分支保护现已启用

---

## 🔍 验证配置成功

配置完成后，你会看到：

1. **Rules** 部分显示 `main` 规则
2. 规则详情展示所有已启用的保护选项
3. 下次 PR 时会自动显示检查状态

---

## 📋 工作流程说明

完成配置后，团队成员的工作流程：

```
1. 创建新分支
   git checkout -b feature/your-feature

2. 进行代码更改
   # 编辑代码...

3. 提交并推送
   git add .
   git commit -m "feat: add new feature"
   git push origin feature/your-feature

4. 创建 Pull Request (PR)
   - 在 GitHub 上打开 PR 到 main 分支
   - 填写 PR 描述

5. 自动运行 CI/CD 检查
   ✓ RSpec 后端测试
   ✓ RuboCop 代码质量
   ✓ Brakeman 安全扫描
   ✓ Vite 前端构建
   ✓ Cucumber 集成测试

6. 代码审查
   - 至少需要 1 个批准
   - 检查代码逻辑和风格

7. 合并到 main
   - 所有检查通过 ✅
   - 获得审核批准 ✅
   - 点击 "Merge" 按钮
   - PR 自动关闭

8. 自动部署 (如已配置)
   - main 分支更新时自动部署
```

---

## ⚠️ 常见问题

### Q1: CI/CD 检查失败怎么办？

**A:** 本地修复问题然后重新推送：
```bash
# 查看失败原因
git push origin feature/your-feature

# 本地测试
bundle exec rspec                    # 后端测试
npm run build                        # 前端构建

# 修复问题后重新推送
git add .
git commit -m "fix: resolve CI issues"
git push origin feature/your-feature
```

### Q2: 怎样跳过检查？

**A:** 不建议跳过！但如果必须：
- 只有推送到 main 的管理员才能强制合并
- 其他分支可以使用 `git push --force-with-lease`

### Q3: 如何更新保护规则？

**A:** 回到 Settings → Branches → 点击规则名称进行编辑

### Q4: 可以禁用分支保护吗？

**A:** 可以，但不推荐。Settings → Branches → Delete rule

---

## 🎓 最佳实践

1. ✅ **始终创建 feature 分支**
   ```bash
   git checkout -b feature/user-authentication
   ```

2. ✅ **定期合并主分支**
   ```bash
   git merge origin/main
   ```

3. ✅ **本地测试后再推送**
   ```bash
   bundle exec rspec
   npm run build
   ```

4. ✅ **编写清晰的提交信息**
   ```
   feat: add user login feature
   fix: resolve database connection timeout
   docs: update API documentation
   ```

5. ✅ **及时处理 PR 反馈**

---

## 🚀 配置完成检查清单

- [ ] 打开 Settings 菜单
- [ ] 找到 Branches 部分
- [ ] 添加分支保护规则
- [ ] 规则应用到 `main` 分支
- [ ] 启用 PR 审查要求
- [ ] 启用 CI/CD 检查
- [ ] 勾选所有必需的状态检查
- [ ] 保存规则
- [ ] 确认规则已显示在规则列表中

✅ 所有项目完成！分支保护已启用

---

## 📞 帮助资源

- [GitHub 官方文档 - Protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [我们的 CI/CD 设置文档](CI_CD_SETUP.md)
- [项目快速开始指南](CI_CD_QUICK_START.md)

