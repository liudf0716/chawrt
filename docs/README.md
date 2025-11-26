# chawrt GitHub Pages

本目录包含 chawrt 项目的 GitHub Pages 网站代码。

## 📁 目录结构

```
docs/
├── index.html          # 主页（项目介绍、编译指南、设备列表）
├── style.css           # 全局样式表
├── data/               # 数据文件
│   └── devices.json    # 设备列表配置（JSON格式）
├── devices/            # 设备详情页（每个设备一个HTML文件）
│   ├── cmcc-rax3000m.html
│   ├── fastrhino-r66s.html
│   ├── newifi-d2.html
│   └── ...             # 新增设备页面
├── js/                 # JavaScript 脚本
│   └── devices.js      # 设备列表动态加载
└── assets/             # 静态资源（图片、图标等）
```

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

### 添加新设备（推荐方式）

模块化结构使得添加新设备非常简单：

**步骤 1：在 `data/devices.json` 中添加设备信息**

```json
{
  "id": "xiaomi-ax3000",
  "name": "Xiaomi AX3000",
  "chip": "MediaTek MT7981B",
  "platform": "mediatek",
  "status": "stable",
  "specs": {
    "cpu": "MediaTek MT7981B (2×ARM Cortex-A53 @ 1.3GHz)",
    "ram": "256MB DDR3",
    "flash": "128MB NAND",
    "wifi": "WiFi 6 双频",
    "ports": "4×GbE"
  }
}
```

**步骤 2：复制设备模板创建详情页**

```bash
cd docs/devices
cp cmcc-rax3000m.html xiaomi-ax3000.html
```

**步骤 3：修改 `xiaomi-ax3000.html` 中的内容**

- 更新标题、面包屑导航
- 修改设备规格、刷机步骤
- 更新常见问题

**完成！** 主页的设备列表会自动从 JSON 加载并显示新设备。

### 不使用 JavaScript 的替代方案

如果不想使用 JavaScript，可以在 `index.html` 的 `<noscript>` 部分手动添加设备链接。

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

### 模块化架构
- ✅ **独立设备页面**：每个设备单独维护，互不影响
- ✅ **JSON 数据驱动**：设备列表统一管理，易于扩展
- ✅ **主页轻量化**：index.html 大幅精简，加载更快
- ✅ **可维护性强**：新增设备只需 3 步，无需修改主页代码

### 技术亮点
- ✅ 纯 HTML + CSS + 轻量 JS（可选）
- ✅ 支持无 JS 降级（noscript 备选方案）
- ✅ 深色主题，适合技术文档
- ✅ 响应式布局，完美适配移动设备
- ✅ SEO 友好，每个设备独立 URL
- ✅ 语义化 HTML5 结构
- ✅ 可访问性友好
- ✅ 打印样式优化

## 许可证

本文档遵循项目的 GPL-2.0 许可证。
