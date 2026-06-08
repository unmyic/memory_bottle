# Memory Bottle

记忆漂流瓶 — 一个基于 Flutter 的个人记忆记录应用。

写下你的记忆，让它像漂流瓶一样在时间中漂浮。随时可以拾起过去的片段，重温那些被遗忘的时刻。

## 功能

- **写下记忆** — 支持内容、标签和自定义日期
- **浏览记忆** — 按时间线分组浏览，支持关键词搜索和多维筛选（日期 + 标签）
- **漂流瓶** — 随机拾取过去的记忆，像在海滩上捡到一个瓶子
- **编辑与删除** — 随时修改或移除已保存的记忆
- **暗色模式** — 支持浅色 / 深色 / 跟随系统三种模式
- **数据导出** — 一键导出所有记忆为 JSON 并分享
- **本地存储** — SQLite 离线存储，数据完全在本地

## 技术栈

| 层 | 技术 |
|---|------|
| 框架 | Flutter 3.x / Dart |
| 状态管理 | Provider |
| 数据库 | SQLite (sqflite) |
| 主题 | Material 3，支持亮色/暗色自动切换 |
| 导出 | share_plus |
| 测试 | flutter_test |

## 项目结构

```
lib/
├── main.dart
├── database/          # SQLite 数据库层
├── models/            # 数据模型
├── pages/             # 页面
├── providers/         # Provider 状态管理
├── services/          # 业务逻辑
├── theme/             # 主题配置
├── utils/             # 工具函数
└── widgets/           # 可复用组件
```

## 发布

- Android (APK)
- Windows (桌面版)

## 未来计划

- 云端同步
- iOS / macOS 发布
- 图片附件
- 记忆提醒

## 作者

unmyic
