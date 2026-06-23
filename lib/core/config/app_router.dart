import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_colors.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/attendance/attendance_screen.dart';
import '../../presentation/screens/timetable/timetable_screen.dart';
import '../../presentation/screens/assignments/assignments_screen.dart';
import '../../presentation/screens/notes/notes_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/add/add_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/policy_screen.dart';
import '../../domain/models/note_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authRefresh = GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges());

  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final location = state.uri.path;
      final isAuthRoute = location == '/' || location == '/login' || location == '/register';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final location = state.uri.path;
          int index = 0;
          if (location.startsWith('/attendance')) {
            index = 1;
          } else if (location.startsWith('/timetable')) {
            index = 2;
          } else if (location.startsWith('/assignments')) {
            index = 3;
          } else if (location.startsWith('/notes')) {
            index = 4;
          }
          return _MainShell(selectedIndex: index, child: child);
        },
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/attendance', builder: (context, state) => const AttendanceScreen()),
          GoRoute(path: '/timetable', builder: (context, state) => const TimetableScreen()),
          GoRoute(path: '/assignments', builder: (context, state) => const AssignmentsScreen()),
          GoRoute(path: '/notes', builder: (context, state) => const NotesScreen()),
        ],
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddScreen(),
      ),
      GoRoute(
        path: '/policy',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PolicyScreen(
            title: extra?['title'] ?? 'Policy',
            content: extra?['content'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/note-editor',
        builder: (context, state) {
          final extra = state.extra as NoteModel?;
          return NoteEditorScreen(note: extra);
        },
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _MainShell extends ConsumerStatefulWidget {
  final int selectedIndex;
  final Widget child;

  const _MainShell({required this.selectedIndex, required this.child});

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  late final PageController _pageController;
  late int _index;

  final List<(String, String, IconData)> _tabs = [
    ('/home', 'Home', LucideIcons.home),
    ('/attendance', 'Attendance', LucideIcons.checkCircle),
    ('/timetable', 'Timetable', LucideIcons.calendar),
    ('/assignments', 'Tasks', LucideIcons.layoutList),
    ('/notes', 'Notes', LucideIcons.fileText),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.selectedIndex;
    _pageController = PageController(initialPage: _index);
  }

  @override
  void didUpdateWidget(_MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _index) {
      _index = widget.selectedIndex;
      if (_pageController.hasClients) _pageController.jumpToPage(_index);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    _pageController.jumpToPage(index);
    // Tap is discrete (instant jump) so syncing the route here is smooth and
    // keeps go_router/back-stack consistent. Swipes intentionally skip this.
    context.go(_tabs[index].$1);
  }

  void _onPageChanged(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // If not on Home tab, go to Home. If on Home, exit the app.
        if (_index != 0) {
          _onTabTapped(0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: false,
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: const [
            _KeepAlivePage(child: HomeScreen()),
            _KeepAlivePage(child: AttendanceScreen()),
            _KeepAlivePage(child: TimetableScreen()),
            _KeepAlivePage(child: AssignmentsScreen()),
            _KeepAlivePage(child: NotesScreen()),
        ],
      ),
      floatingActionButton: _index == 0 ? FloatingActionButton(
        onPressed: () => context.push('/add'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: const Icon(LucideIcons.plus, size: 28),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 8,
          top: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_tabs.length, (index) {
            final isSelected = _index == index;
            final tab = _tabs[index];
            return Expanded(
              child: GestureDetector(
                onTap: () => _onTabTapped(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.$3,
                        color: isSelected ? AppColors.primary : AppColors.textTertiary,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textTertiary,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      ),  // closes Scaffold
    );   // closes PopScope
  }
}

/// Keeps a tab's screen (and its state/data) alive when it scrolls off-screen
/// in the PageView, so switching tabs doesn't rebuild or re-fetch.
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(child: widget.child);
  }
}
