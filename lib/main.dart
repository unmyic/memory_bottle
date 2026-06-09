import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'config/supabase_config.dart';
import 'services/cloud_sync_service.dart';
import 'theme/app_theme.dart';
import 'providers/memory_provider.dart';
import 'providers/settings_provider.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 加载持久化设置
  final settingsProvider = SettingsProvider();
  await settingsProvider.load();

  // 初始化云同步（如果已配置 Supabase）
  if (SupabaseConfig.url != 'YOUR_SUPABASE_URL') {
    try {
      await CloudSyncService().initialize();
    } catch (_) {
      // 云同步初始化失败不影响本地使用
    }
  }

  runApp(MemoryBottleApp(settingsProvider: settingsProvider));
}

class MemoryBottleApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  const MemoryBottleApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    final useCloud = CloudSyncService().isInitialized;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
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
            home: useCloud ? const _AuthGate() : const HomePage(),
          );
        },
      ),
    );
  }
}

/// 认证守卫：未登录显示登录页，已登录显示主页
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final client = CloudSyncService().client;

    return StreamBuilder(
      stream: client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (client.auth.currentUser != null) {
          return const HomePage();
        }
        return const AuthPage();
      },
    );
  }
}
