import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/config/app_config.dart';
import 'core/config/firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/revenuecat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase safely (avoid duplicate-app on Android)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase init warning (using native default): $e');
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (_) {}
  }

  // Initialize Hive local storage safely
  try {
    await Hive.initFlutter();
    await Hive.openBox(AppConfig.settingsBox);
    await Hive.openBox(AppConfig.pulseBox);
    await Hive.openBox(AppConfig.userBox);
  } catch (e) {
    debugPrint('Hive init error: $e');
  }

  // Initialize timezone for notifications safely
  try {
    tz.initializeTimeZones();
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  // Initialize RevenueCat safely
  try {
    await RevenueCatService.instance.initialize();
  } catch (e) {
    debugPrint('RevenueCat init error: $e');
  }

  runApp(
    const ProviderScope(
      child: StaffPulseApp(),
    ),
  );
}

class StaffPulseApp extends ConsumerWidget {
  const StaffPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'StaffPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
