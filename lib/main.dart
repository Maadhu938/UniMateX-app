import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'core/config/app_router.dart';
import 'data/local/hive_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Offline cache: serve data instantly from disk, then refresh from server.
  // This makes the app feel fast on launch and work offline.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize Notifications (permission is requested after first frame).
  await NotificationService().init();

  runApp(const ProviderScope(
    child: UniMateXApp(),
  ));
}

class UniMateXApp extends ConsumerStatefulWidget {
  const UniMateXApp({super.key});

  @override
  ConsumerState<UniMateXApp> createState() => _UniMateXAppState();
}

class _UniMateXAppState extends ConsumerState<UniMateXApp> {
  @override
  void initState() {
    super.initState();
    // Request notification permission once the Activity is resumed; calling
    // this in main() before runApp is too early for the system dialog to show.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final service = NotificationService();
      await service.requestPermissions();
      await service.requestExactAlarmPermissionIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'UniMateX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
