# 记忆漂流瓶 · Memory Bottle

一个基于 Flutter 的个人记忆记录应用。写下你的记忆，让它像漂流瓶一样在时间中漂浮。随时可以拾起过去的片段，重温那些被遗忘的时刻。

## 功能

- **写下记忆** — 记录内容、标签和自定义日期，支持图片和文档附件
- **浏览记忆** — 按时间线分组浏览，支持关键词搜索和标签筛选
- **漂流瓶** — 随机拾取过去的记忆，像在海滩上捡到一个瓶子
- **编辑与删除** — 随时修改或移除已保存的记忆
- **暗色模式** — 支持浅色 / 深色 / 跟随系统三种模式
- **字体系统** — 内置 12 款精选中文字体，随心切换
- **附件支持** — 图片全屏查看（双指缩放），文档调用系统应用打开
- **云同步** — 基于 Supabase 的云端存储，注册账号后多端自动同步
- **数据导出** — 一键导出所有记忆和附件为备份文件，支持导入恢复
- **设置持久化** — 字体和主题偏好自动保存，重启不丢失

## 截图

> 待补充

## 下载

| 平台 | 状态 |
|------|------|
| Android | [app-release.apk](https://github.com/unmyic/memory_bottle/releases) |
| Windows | memory_bottle.exe |
| iOS / macOS | 计划中 |

## 技术栈

| 层 | 技术 |
|---|------|
| 框架 | Flutter 3.x / Dart |
| 状态管理 | Provider |
| 本地数据库 | SQLite (sqflite) |
| 云后端 | Supabase (PostgreSQL + Storage + Auth) |
| 认证 | Supabase Auth (邮箱密码) |
| 主题 | Material 3 + Google Fonts |
| 文件操作 | image_picker / file_picker / open_filex |
| 持久化 | shared_preferences |
| 测试 | flutter_test |

## 项目结构

```
lib/
├── main.dart                         # 应用入口，初始化与认证守卫
├── config/
│   └── supabase_config.dart          # Supabase 连接配置
├── database/
│   └── memory_database.dart          # SQLite 数据库层
├── models/
│   ├── memory.dart                   # 记忆数据模型
│   └── attachment.dart               # 附件数据模型
├── pages/
│   ├── auth_page.dart                # 登录 / 注册
│   ├── home_page.dart                # 首页（统计、导航、同步状态）
│   ├── write_memory_page.dart        # 写 / 编辑记忆
│   ├── memory_detail_page.dart       # 记忆详情
│   ├── memory_list_page.dart         # 记忆列表（搜索、筛选）
│   ├── bottle_page.dart              # 漂流瓶拾取
│   └── image_viewer_page.dart        # 图片全屏查看
├── providers/
│   ├── memory_provider.dart          # 记忆状态管理（含自动同步）
│   └── settings_provider.dart        # 设置状态管理（主题、字体）
├── services/
│   ├── memory_service.dart           # 记忆业务逻辑
│   └── cloud_sync_service.dart       # Supabase 云同步
├── theme/
│   └── app_theme.dart                # Material 3 主题配置
├── utils/
│   └── date_utils.dart               # 日期格式化工具
└── widgets/
    ├── memory_card.dart              # 记忆列表卡片
    ├── memory_content_card.dart      # 记忆内容展示卡片
    ├── tag_text.dart                 # 标签文本组件
    └── settings_sheet.dart           # 设置面板
```

## 云同步设置

1. 前往 [Supabase](https://supabase.com) 创建项目
2. 在 SQL Editor 运行 `supabase_setup.sql`
3. 在 Authentication → Providers 中启用 Email 登录
4. 将项目 URL 和 publishable key 填入 `lib/config/supabase_config.dart`
5. 重新构建应用

## 构建

```bash
# Android
flutter build apk --release

# Windows
flutter build windows --release

# 运行测试
flutter test
```

## 版本

当前版本：**0.1.4**

详见 [CHANGELOG.md](CHANGELOG.md)

## 作者

unmyic
