import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'theme/app_theme.dart';
import 'providers/memory_provider.dart';
import 'providers/settings_provider.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MemoryBottleApp());
}

class MemoryBottleApp extends StatelessWidget {
  const MemoryBottleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer2<MemoryProvider, SettingsProvider>(
        builder: (context, memoryProvider, settingsProvider, _) {
          // 监听数据库错误
          if (memoryProvider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(memoryProvider.errorMessage!),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
                memoryProvider.errorMessage = null;
              } catch (_) {}
            });
          }

          return MaterialApp(
            scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
            title: '记忆漂流瓶',
            debugShowCheckedModeBanner: false,
            themeMode: settingsProvider.themeMode,
            theme: AppTheme.buildTheme(
                Brightness.light, settingsProvider.currentFont),
            darkTheme: AppTheme.buildTheme(
                Brightness.dark, settingsProvider.currentFont),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
