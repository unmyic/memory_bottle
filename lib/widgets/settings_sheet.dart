import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('设置', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),

              // ---- 主题模式 ----
              Text('主题模式', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: ThemeMode.values.map((mode) {
                  final isSelected = settings.themeMode == mode;
                  final (icon, label) = switch (mode) {
                    ThemeMode.system => (Icons.brightness_auto, '跟随系统'),
                    ThemeMode.light => (Icons.light_mode, '浅色'),
                    ThemeMode.dark => (Icons.dark_mode, '深色'),
                  };
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        selected: isSelected,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 16),
                            const SizedBox(width: 6),
                            Text(label),
                          ],
                        ),
                        onSelected: (_) => _setThemeMode(context, mode),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ---- 字体选择 ----
              Text('字体', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              _FontPickerTile(font: settings.currentFont),
            ],
          ),
        );
      },
    );
  }

  void _setThemeMode(BuildContext context, ThemeMode mode) {
    final settings = context.read<SettingsProvider>();
    while (settings.themeMode != mode) {
      settings.toggleTheme();
    }
  }
}

/// 字体选择入口 — 点击弹出字体列表
class _FontPickerTile extends StatelessWidget {
  final FontOption font;
  const _FontPickerTile({required this.font});

  @override
  Widget build(BuildContext context) {
    final previewColor = Theme.of(context).textTheme.bodyLarge?.color;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showFontPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A3A4A)
                : const Color(0xFFDDEEFF),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                font.label,
                style: _previewStyle(font, 16, previewColor),
              ),
            ),
            Icon(Icons.chevron_right, color: previewColor?.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  void _showFontPicker(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final previewColor = Theme.of(context).textTheme.bodyLarge?.color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('选择字体',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: availableFonts.map((f) {
                    final isSelected = settings.fontName == f.name;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        title: Text(
                          f.label,
                          style: _previewStyle(f, 18, isSelected
                              ? colorScheme.primary
                              : previewColor),
                        ),
                        subtitle: Text(
                          '记忆漂流瓶',
                          style: _previewStyle(f, 14, isSelected
                              ? colorScheme.primary.withValues(alpha: 0.7)
                              : previewColor?.withValues(alpha: 0.5)),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: colorScheme.primary)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        selected: isSelected,
                        selectedTileColor:
                            colorScheme.primary.withValues(alpha: 0.08),
                        onTap: () {
                          settings.setFont(f.name);
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static TextStyle _previewStyle(FontOption font, double fontSize, Color? color) {
    final base = TextStyle(fontSize: fontSize, color: color);
    if (font.fontFamily != null) {
      return base.copyWith(fontFamily: font.fontFamily);
    }
    if (font.previewBuilder != null) {
      return font.previewBuilder!(textStyle: base);
    }
    return base;
  }
}

void showSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const SettingsSheet(),
  );
}
