import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontOption {
  final String name;
  final String label;
  /// 本地 TTF 的 fontFamily（如果有）
  final String? fontFamily;
  /// 应用级 TextTheme 转换
  final TextTheme Function(TextTheme)? googleFontsBuilder;
  /// 单个 TextStyle 预览（设置面板用）
  final TextStyle Function({TextStyle? textStyle})? previewBuilder;

  const FontOption({
    required this.name,
    required this.label,
    this.fontFamily,
    this.googleFontsBuilder,
    this.previewBuilder,
  });
}

final availableFonts = <FontOption>[
  const FontOption(name: 'system', label: '系统默认'),
  FontOption(
    name: 'notoSans',
    label: '思源黑体',
    googleFontsBuilder: GoogleFonts.notoSansScTextTheme,
    previewBuilder: GoogleFonts.notoSansSc,
  ),
  FontOption(
    name: 'notoSerif',
    label: '思源宋体',
    googleFontsBuilder: GoogleFonts.notoSerifScTextTheme,
    previewBuilder: GoogleFonts.notoSerifSc,
  ),
  FontOption(
    name: 'maShan',
    label: '马山行书',
    googleFontsBuilder: GoogleFonts.maShanZhengTextTheme,
    previewBuilder: GoogleFonts.maShanZheng,
  ),
  FontOption(
    name: 'longCang',
    label: '龙藏手写',
    googleFontsBuilder: GoogleFonts.longCangTextTheme,
    previewBuilder: GoogleFonts.longCang,
  ),
  FontOption(
    name: 'zcool',
    label: '站酷小薇',
    googleFontsBuilder: GoogleFonts.zcoolXiaoWeiTextTheme,
    previewBuilder: GoogleFonts.zcoolXiaoWei,
  ),
  const FontOption(
    name: 'sanJi',
    label: '三极行楷',
    fontFamily: 'SanJiXingKai',
  ),
  const FontOption(
    name: 'jiZi',
    label: '极字行楷',
    fontFamily: 'JiZiXingKai',
  ),
  const FontOption(
    name: 'huiWen',
    label: '汇文正楷',
    fontFamily: 'HuiWenZhengKai',
  ),
  const FontOption(
    name: 'yanShi',
    label: '演示夏行楷',
    fontFamily: 'YanShiXiaXingKai',
  ),
  const FontOption(
    name: 'yuWei',
    label: '禹卫行书',
    fontFamily: 'YuWeiXingShu',
  ),
  const FontOption(
    name: 'qingKe',
    label: '庆科黄油',
    fontFamily: 'ZCOOLQingKeHuangYou',
  ),
  const FontOption(
    name: 'kuaiLe',
    label: '站酷快乐体',
    fontFamily: 'ZCOOLKuaiLeTi',
  ),
];

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  String _fontName = 'notoSerif';
  String get fontName => _fontName;

  FontOption get currentFont =>
      availableFonts.firstWhere((f) => f.name == _fontName);

  void toggleTheme() {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.dark;
      case ThemeMode.dark:
        _themeMode = ThemeMode.light;
      case ThemeMode.light:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void setFont(String name) {
    _fontName = name;
    notifyListeners();
  }
}
