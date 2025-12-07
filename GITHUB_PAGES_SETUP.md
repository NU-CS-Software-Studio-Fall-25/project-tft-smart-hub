# GitHub Pages Configuration for TFT Smart Hub

## 📚 API Documentation on GitHub Pages

本项目在 GitHub 上托管 API 文档，以便团队成员和用户可以直接在浏览器中查看。

## 🔗 访问文档

### 方式 1：直接从 GitHub 查看（推荐）

在项目 README 中的链接：
```
[View API Docs](./ruby_backend/tft_team_builder/doc/index.html)
```

点击链接即可在 GitHub 上查看格式化的文档。

### 方式 2：通过 GitHub Pages（需要配置）

如果启用了 GitHub Pages，可以访问：
```
https://NU-CS-Software-Studio-Fall-25.github.io/project-tft-smart-hub/ruby_backend/tft_team_builder/doc/
```

## 📝 如何更新文档

### 本地生成

```bash
cd /home/zrt/NU/CS397_SoftwareStudio/project/project-tft-smart-hub
./generate-docs.sh
```

### 提交到 GitHub

```bash
git add ruby_backend/tft_team_builder/doc/
git commit -m "docs: update API documentation"
git push origin main
```

## 🎯 GitHub Pages 启用步骤

如果要启用 GitHub Pages 的完整功能：

1. **前往 Repository Settings**
   - 打开项目的 Settings 页面
   - 找到 "Pages" 部分

2. **配置 Pages Source**
   - **Source**: 选择 "Deploy from a branch"
   - **Branch**: 选择 "main"
   - **Folder**: 选择 "/ (root)"

3. **等待部署**
   - GitHub 会自动部署
   - 访问 URL: `https://NU-CS-Software-Studio-Fall-25.github.io/project-tft-smart-hub/`

## 📁 目录结构

```
project-tft-smart-hub/
├── ruby_backend/tft_team_builder/doc/     ← API 文档
│   ├── index.html                         ← 主入口
│   ├── User.html
│   ├── TeamComp.html
│   ├── TeamCompsController.html
│   └── [所有其他文档]
└── [其他项目文件]
```

## 🔄 自动化更新

### GitHub Actions 流程（可选）

可以添加 GitHub Actions 工作流来自动生成和更新文档：

```yaml
name: Generate Documentation

on: [push]

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3.4'
          bundler-cache: true
      
      - name: Generate Docs
        run: |
          cd ruby_backend/tft_team_builder
          bundle exec yard doc
      
      - name: Commit and Push
        run: |
          git add ruby_backend/tft_team_builder/doc/
          git commit -m "docs: auto-generated documentation" || true
          git push
```

## 💡 提示

- 文档文件（`.html`）已从 `.gitignore` 中移除，可以被 Git 追踪
- 每次修改代码注释后，记得运行 `./generate-docs.sh` 重新生成文档
- 文档会随着 `git push` 自动更新在 GitHub 上

## 📞 支持

查看以下文档获取更多信息：
- `DOCS_COMPLETED.md` - 文档系统完成总结
- `DOCUMENTATION_GUIDE.md` - 详细的文档编写指南
- `DOCS_QUICK_REF.md` - 快速参考
