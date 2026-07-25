# 记忆漂流瓶 (Memory Bottle)

一个简洁纯粹的私人记忆记录应用。写下你的记忆，扔进漂流瓶，随时拾取回忆。

## ✨ 特点

- **纯本地存储** — 数据保存在本地 JSON 文件中，无需网络，无需账号，你的记忆只属于你
- **全平台支持** — Windows、macOS、Linux、Android、iOS、Web 全平台可用
- **极简设计** — 单文件架构，不到 600 行代码，轻量易维护
- **导入/导出** — 一键导出备份到桌面，支持从备份文件恢复数据
- **漂流瓶** — 随机拾取一段记忆，重温过去的时光
- **零原生依赖** — 构建无需任何原生编译环境，开箱即用

## 🚀 快速开始

### 环境要求

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.44

### 运行

```bash
# 克隆项目
git clone https://github.com/unmyic/memory_bottle.git
cd memory_bottle

# 安装依赖
flutter pub get

# 运行（自动检测当前平台）
flutter run
```

### 构建

```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux

# Android
flutter build apk

# iOS
flutter build ios
```

## 📁 数据存储

所有数据以 JSON 格式存储，位置因平台而异：

| 平台 | 路径 |
|------|------|
| Windows | `C:\Users\<用户名>\Documents\MemoryBottle\memory_bottle.json` |
| macOS | `~/Documents/MemoryBottle/memory_bottle.json` |
| Linux | `~/.local/share/MemoryBottle/memory_bottle.json` |
| Android / iOS | `~/memory_bottle.json` |

导出备份文件默认保存到**桌面**，文件名格式：`记忆漂流瓶_备份_YYYY-MM-DD.json`

## 🔄 跨设备迁移

由于应用采用纯本地存储，需要在设备间手动迁移数据：

1. 在设备 A 上点击 **「导出备份」**，将 JSON 文件发送到设备 B
2. 在设备 B 上点击 **「导入备份」**，选择收到的 JSON 文件即可

## 🏗️ 项目结构

```
memory_bottle/
├── lib/
│   └── main.dart          # 应用全部代码（单文件）
├── test/
│   └── widget_test.dart   # 基础 UI 测试
├── android/               # Android 平台配置
├── ios/                   # iOS 平台配置
├── linux/                 # Linux 平台配置
├── macos/                 # macOS 平台配置
├── windows/               # Windows 平台配置
├── web/                   # Web 平台配置
└── pubspec.yaml           # 项目依赖
```

## 📋 依赖

| 依赖 | 用途 |
|------|------|
| `file_picker` | 导入备份时选择文件 |

核心功能仅依赖 Flutter SDK 和 `dart:io`，第三方依赖极简。

## 📄 许可

MIT License
