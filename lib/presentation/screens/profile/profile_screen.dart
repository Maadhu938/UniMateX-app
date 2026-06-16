import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../auth/policy_screen.dart';
import '../../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/notification_service.dart';

/// Reads the real app version (and build number) from the platform so the
/// profile footer always matches pubspec — no manual edits per release.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final name = ref.watch(userDisplayNameProvider).valueOrNull ?? 'Student';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textMain),
        ),
        title: Text(AppStrings.profile, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Header (Centered Circular)
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                        image: photoUrl != null ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover) : null,
                      ),
                      child: photoUrl == null 
                        ? Center(child: Text(initial, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary)))
                        : null,
                    ),
                    GestureDetector(
                      onTap: () => _showEditNameDialog(context, ref, name),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(LucideIcons.pencil, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Settings Group
          _buildSectionHeader("Account & Preferences"),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: LucideIcons.bell,
            title: "Notifications",
            onTap: () => _showNotificationsDialog(context, ref),
            subtitle: "Manage alerts",
          ),
          
          const SizedBox(height: 32),
          
          _buildSectionHeader("Support & About"),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: LucideIcons.helpCircle,
            title: "Help Center",
            onTap: () => context.push('/policy', extra: {'title': 'Help Center', 'content': _realHelpContent}),
          ),
          _buildSettingTile(
            icon: LucideIcons.shieldCheck,
            title: "Privacy Policy",
            onTap: () => context.push('/policy', extra: {'title': 'Privacy Policy', 'content': PolicyScreen.dummyPrivacy}),
          ),
          
          const SizedBox(height: 40),
          
          // Logout Button
          ElevatedButton(
            onPressed: () => _showLogoutDialog(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textMain,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.logOut, size: 20),
                SizedBox(width: 8),
                Text("Log Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Delete Account
          TextButton(
            onPressed: () => _showDeleteDialog(context, ref),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text("Delete Account", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                const Text(
                  "Made with ❤️ by Maadhu",
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  "UniMateX v${ref.watch(appVersionProvider).valueOrNull ?? '1.0.0'}",
                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMain)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)) : null,
        trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textTertiary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Profile Name"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: "Full Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                final user = ref.read(authServiceProvider).currentUser;
                if (user != null) {
                  await user.updateDisplayName(newName);
                  ref.invalidate(userDisplayNameProvider);
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final isEnabled = ref.watch(notificationsEnabledProvider);
          
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(LucideIcons.bell, color: AppColors.primary),
                SizedBox(width: 12),
                Text("Reminders"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Get notified 15 minutes before your lectures start. We recommend keeping this ON to stay organized.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  value: isEnabled,
                  onChanged: (value) async {
                    final messenger = ScaffoldMessenger.of(context);
                    ref.read(notificationsEnabledProvider.notifier).state = value;
                    await ref.read(settingsServiceProvider).setNotificationsEnabled(value);

                    if (value) {
                      final service = NotificationService();
                      await service.init();
                      final granted = await service.requestPermissions();
                      await service.requestExactAlarmPermissionIfNeeded();
                      if (!granted) {
                        messenger.showSnackBar(const SnackBar(
                          content: Text('Notifications are blocked. Enable them in Settings > Apps > UniMateX > Notifications.'),
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    } else {
                      await NotificationService().cancelAllNotifications();
                    }
                  },
                  title: const Text(
                    "Enable Reminders",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
                if (!isEnabled)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "To fully revoke system permissions, please visit App Info > Notifications in your phone settings.",
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Done"),
              ),
            ],
          );
        },
      ),
    );
  }

  String get _realHelpContent => """
## Getting Started with UniMateX

Welcome to your academic companion. Here is how to get the most out of UniMateX.

### Timetable and Schedule
- **Add classes**: Use the '+' button or the Timetable tab to build your weekly schedule.
- **Now and Next**: When viewing today, the ongoing class and your next class are highlighted.
- **Auto-sync**: Your schedule is backed up to the cloud. Sign in on any device to see it.

### Attendance Tracking
- **Marking attendance**: In the Attendance tab, tap 'Present' or 'Absent' after each class.
- **Smart warnings**: Subjects are color-coded as Safe, Warning, or Danger based on your target percentage.
- **Bunk calculator**: See how many classes you can safely skip, or how many more you need to attend to stay on target.
- **Targets**: Tap the settings icon on a subject to set its target percentage and semester total.

### Notes and Assignments
- **Cloud notes**: Write lecture notes that are instantly available across your devices.
- **Assignment deadlines**: Track pending tasks with due dates and get reminders before they are due.

### Account and Data
- **Privacy**: Your data is private to your account and protected by secure access rules.
- **Delete account**: You can permanently remove all your cloud and local data from the Profile screen.

---
**Need more help?**
Contact us at **support@unimatex.app**
""";

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) context.go('/login');
            },
            child: const Text("Log Out", style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account", style: TextStyle(color: AppColors.danger)),
        content: const Text("This action is permanent and cannot be undone. All your data will be permanently wiped from our servers and your device."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final rootContext = context;
              navigator.pop();

              // Show a blocking progress indicator while we delete.
              showDialog(
                context: rootContext,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              try {
                await ref.read(authServiceProvider).deleteAccount();
                if (rootContext.mounted) {
                  Navigator.of(rootContext, rootNavigator: true).pop(); // close progress
                  rootContext.go('/login');
                }
              } catch (e) {
                if (rootContext.mounted) {
                  Navigator.of(rootContext, rootNavigator: true).pop(); // close progress
                  final message = e is FirebaseAuthException ? (e.message ?? 'Could not delete account.') : 'Could not delete account. Please try again.';
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: const Text("Confirm Delete"),
          ),
        ],
      ),
    );
  }
}
