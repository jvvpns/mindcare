import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindcare/core/services/hive_service.dart';
import 'package:mindcare/core/services/supabase_service.dart';
import 'package:mindcare/core/services/connectivity_service.dart';
import 'package:mindcare/core/router/app_router.dart';
import 'package:mindcare/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize core services
  await HiveService.instance.init();
  await SupabaseService.instance.init();
  await ConnectivityService.instance.init();

  runApp(
    const ProviderScope(
      child: MindCareApp(),
    ),
  );
}

class MindCareApp extends ConsumerWidget {
  const MindCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'MindCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}