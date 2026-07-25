# Changelog

本文件记录「记忆漂流瓶」的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

---

## [2.0.0] - 2026-07-25

### 重大变更

- **移除云同步功能**：因云服务收费，彻底移除 Supabase 云同步和邮箱登录功能
- **存储方式变更**：从 SQLite 数据库迁移至纯 JSON 文件存储
- **架构简化**：从多文件 Provider 架构回归单文件应用（`lib/main.dart`）

### 移除

- Supabase 云同步服务（`CloudSyncService`）
- 邮箱登录/注册功能（`AuthPage`）
- Provider 状态管理（`MemoryProvider`、`SettingsProvider`）
- 多文件页面架构（`lib/pages/`、`lib/widgets/` 等）
- 所有 SQLite 相关依赖（`sqflite`、`sqflite_common_ffi`、`sqlite3`）
- 大量间接依赖（`share_plus`、`path_provider`、`objective_c` 等）

### 新增

- 纯 Dart JSON 文件存储（零原生编译依赖）
- 数据导出功能：一键导出 JSON 备份到桌面
- 数据导入功能：通过文件选择器导入备份文件

### 变更

- 依赖数量从 15+ 个减少到 1 个（`file_picker`）
- 应用启动不再需要 FFI 初始化
- 数据存储位置移至用户文档目录（`Documents/MemoryBottle/`）

### 修复

- 修复 Flutter SDK 路径含空格时无法编译的问题
- 修复网络受限环境下（GitHub 不可访问）构建失败的问题

---

## [1.0.0] - 2025-06-05

### 新增

- 初始版本
- 写入记忆、查看记忆列表、编辑/删除记忆
- 随机「漂流瓶」拾取功能
- 基于 Supabase 的云同步（邮箱登录，多端数据互通）
- SQLite 本地数据库（sqflite）
- Material 3 设计风格
- 全平台支持（Windows / macOS / Linux / Android / iOS）
