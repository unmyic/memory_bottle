import 'package:flutter/material.dart';

import '../providers/settings_provider.dart';

class AppTheme {
  static const Color primary = Color(0xFF4A9FE7);

  static const Color lightBg = Color(0xFFF4FAFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextMain = Color(0xFF1F2D3D);
  static const Color lightTextMuted = Color(0xFF6B7C8F);
  static const Color lightCardBorder = Color(0xFFDDEEFF);

  static const Color darkBg = Color(0xFF0F1A24);
  static const Color darkSurface = Color(0xFF192837);
  static const Color darkTextMain = Color(0xFFE8EDF2);
  static const Color darkTextMuted = Color(0xFF8B9DB5);
  static const Color darkCardBorder = Color(0xFF1F3850);

  static ThemeData buildTheme(Brightness brightness, FontOption font) {
    final isDark = brightness == Brightness.dark;

    final background = isDark ? darkBg : lightBg;
    final surface = isDark ? darkSurface : lightSurface;
    final textMain = isDark ? darkTextMain : lightTextMain;
    final textMuted = isDark ? darkTextMuted : lightTextMuted;
    final cardBorder = isDark ? darkCardBorder : lightCardBorder;

    final baseTextTheme = TextTheme(
      headlineMedium: TextStyle(
        color: textMain, fontSize: 28, fontWeight: FontWeight.w800, height: 1.25,
      ),
      headlineSmall: TextStyle(
        color: textMain, fontSize: 22, fontWeight: FontWeight.w700, height: 1.3,
      ),
      titleLarge: TextStyle(
        color: textMain, fontSize: 20, fontWeight: FontWeight.w700, height: 1.3,
      ),
      titleMedium: TextStyle(
        color: textMain, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4,
      ),
      bodyLarge: TextStyle(
        color: textMain, fontSize: 16, height: 1.6,
      ),
      bodyMedium: TextStyle(
        color: textMuted, fontSize: 14, height: 1.5,
      ),
      bodySmall: TextStyle(
        color: textMuted, fontSize: 12, height: 1.4,
      ),
      labelLarge: TextStyle(
        color: textMain, fontSize: 15, fontWeight: FontWeight.w700, height: 1.3,
      ),
      labelMedium: TextStyle(
        color: textMain, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3,
      ),
      labelSmall: TextStyle(
        color: textMain, fontSize: 11, fontWeight: FontWeight.w500, height: 1.3,
      ),
    );

    // 应用字体：优先用本地 TTF，否则用 google_fonts
    final textTheme = _resolveFont(baseTextTheme, font);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      scaffoldBackgroundColor: background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: const Color(0xFF7BC7F2),
        surface: surface,
        error: const Color(0xFFE57373),
      ),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: textMain,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),

      textTheme: textTheme,

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: cardBorder, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(120, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(120, 50),
          side: const BorderSide(color: primary, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 15,
        ),
        labelStyle: TextStyle(color: textMuted),
        hintStyle: TextStyle(
            color: isDark ? const Color(0xFF5A6D82) : const Color(0xFF9AAABD)),
        prefixIconColor: primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: textMain,
        contentTextStyle: TextStyle(
          color: isDark ? darkBg : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF1F3850) : const Color(0xFFE5F1FA),
        thickness: 1,
        space: 24,
      ),
    );
  }

  static TextTheme _resolveFont(TextTheme base, FontOption font) {
    // 优先使用本地 TTF
    if (font.fontFamily != null) {
      return base.apply(fontFamily: font.fontFamily);
    }
    // 回退到 google_fonts
    if (font.googleFontsBuilder != null) {
      return font.googleFontsBuilder!(base);
    }
    // 系统默认
    return base;
  }
}
