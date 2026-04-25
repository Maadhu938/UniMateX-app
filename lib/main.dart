import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'core/config/app_router.dart';
import 'core/services/auth_service.dart';
import 'data/local/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: UniMateXApp()));
}

class UniMateXApp extends ConsumerWidget {
  const UniMateXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return _AppLifecycleLogout(
      child: MaterialApp.router(
        title: 'UniMateX',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}

class _AppLifecycleLogout extends StatefulWidget {
  final Widget child;

  const _AppLifecycleLogout({required this.child});

  @override
  State<_AppLifecycleLogout> createState() => _AppLifecycleLogoutState();
}

class _AppLifecycleLogoutState extends State<_AppLifecycleLogout>
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Log out only when app is detached (closed), not on simple backgrounding.
    if (state == AppLifecycleState.detached) {
      unawaited(_authService.signOut());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
