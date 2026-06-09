# Changelog

All notable changes to Memory Bottle (记忆漂流瓶) will be documented in this file.

---

## [0.1.4] — 2026-06-09

### Added
- Cloud sync via Supabase (PostgreSQL + Storage)
- Email/password account system (sign up / sign in / sign out)
- Auto-sync: pushes on save/edit/delete, pulls on startup and app resume
- Image viewer with pinch-to-zoom (0.5x–4.0x)
- Open document attachments (PDF, TXT, etc.) via system apps
- Custom app icon across Android, iOS, and Windows
- App display name "记忆漂流瓶" on all platforms
- Settings persistence: font and theme preferences survive app restart

### Changed
- Replace manual cloud upload/download buttons with auto-sync status icon
- Settings panel uses `Wrap` layout to prevent text overflow

### Fixed
- Release APK missing `INTERNET` permission causing cloud sync failure
- Cloud sync deduplication failure due to `DateTime` precision mismatch
- Package name typo: `memory_bootle` → `memory_bottle` (all platforms)
- "Follow system" text overflow in settings panel
- Hero animation `RenderFlex` overflow on card transition

---

## [0.1.3] — 2026-06-08

### Added
- 12 Chinese fonts: Noto Sans SC, Noto Serif SC, Ma Shan Zheng, Long Cang, ZCOOL XiaoWei, SanJi XingKai, JiZi XingKai, HuiWen ZhengKai, YanShi XiaXingKai, YuWei XingShu, ZCOOL QingKe HuangYou, ZCOOL KuaiLe Ti
- Settings panel redesign with live font preview

### Fixed
- Button text not respecting selected font
- Bottle page animation removed (performance)

---

## [0.1.2] — 2026-06-08

### Added
- Dark mode: light / dark / follow system
- Hero animation from list card to detail page
- Data export: one-tap JSON backup with attachments (base64)
- Pull-to-refresh on memory list
- Delete confirmation toast

### Changed
- Migrated state management to Provider
- Merged write/edit memory pages (reduced ~120 lines of duplicate code)
- Extracted shared `MemoryContentCard` widget
- Added 300ms debounce to search input
- Improved database error handling with SnackBar feedback

### Added
- 28 unit tests covering Memory model, date utils, and MemoryService

---

## [0.1.1] — 2026-06-07

### Added
- Memory list with date-grouped timeline
- Keyword search and tag filtering
- Tag input with chip display

---

## [0.1.0] — 2026-06-07

### Added
- Write memories with content, tags, and custom date
- Bottle pickup: randomly retrieve past memories
- Edit and delete memories
- SQLite local storage
- Android and Windows release
