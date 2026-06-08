import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.light:
        return Icons.light_mode;
    }
  }

  String get themeLabel {
    switch (_themeMode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.light:
        return '浅色模式';
    }
  }
}
