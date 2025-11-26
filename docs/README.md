# chawrt GitHub Pages

本目录包含 chawrt 项目的 GitHub Pages 网站代码。

## 文件说明

- `index.html` - 主页面文件
- `style.css` - 样式表
- `assets/` - 资源文件目录（图片、图标等）

## 启用 GitHub Pages

1. 进入 GitHub 仓库设置页面
2. 找到 "Pages" 设置项
3. Source 选择 `main` 分支
4. 目录选择 `/docs`
5. 点击 Save

几分钟后，网站将在 `https://liudf0716.github.io/chawrt/` 上线。

## 本地预览

在 docs 目录下运行简单的 HTTP 服务器：

```bash
# Python 3
python3 -m http.server 8000

# Node.js (需要先安装 http-server)
npx http-server

# PHP
php -S localhost:8000
```

然后在浏览器访问 `http://localhost:8000`

## 维护说明

### 添加新设备

在 `index.html` 的设备支持区域，复制现有的 `<details class="device-card">` 结构，修改设备信息即可。

### 更新编译步骤

修改编译指南区域的 `<div class="step">` 内容。

### 样式调整

所有样式定义在 `style.css` 中，使用 CSS 变量可快速调整配色方案。

## 自定义配色

编辑 `style.css` 顶部的 CSS 变量即可更改配色：

```css
:root {
    --bg-primary: #0d1117;      /* 主背景色 */
    --accent-primary: #58a6ff;  /* 主强调色 */
    /* ... 其他颜色 */
}
```

## 技术特性

- ✅ 纯 HTML + CSS，无需 JavaScript
- ✅ 深色主题，适合技术文档
- ✅ 响应式布局，支持移动设备
- ✅ 语义化 HTML5 结构
- ✅ 可访问性友好
- ✅ 打印样式优化

## 许可证

本文档遵循项目的 GPL-2.0 许可证。
