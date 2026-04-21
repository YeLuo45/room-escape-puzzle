# Room Escape Puzzle

A Godot 4.x escape room puzzle game.

## 运行方式

1. 安装 [Godot 4.2+](https://godotengine.org/download)
2. 克隆仓库后，用 Godot 打开项目根目录
3. 点击运行即可

## 构建产物

GitHub Actions 自动构建，每次提交到 `main` 分支会生成：
- Windows x86_64 便携版 (.exe)
- Linux x86_64 便携版
- macOS 版本

构建产物在 GitHub Actions 页面 `Actions` tab 或 Release 页面下载。

## 部署

发布版本通过 GitHub Releases 分发。请确保在 GitHub 仓库设置中添加 `GODOT_AUTH_TOKEN` secret 用于导出。

## 目录结构

```
src/
├── scenes/          # 场景文件 (.tscn)
├── scripts/         # GDScript 脚本
├── resources/       # 游戏资源（物品、关卡、音频）
│   ├── items/
│   ├── levels/
│   └── audio/
└── assets/          # 静态资源（图片、字体）
    ├── sprites/
    └── fonts/
```
