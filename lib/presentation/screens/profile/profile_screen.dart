import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/policy_screen.dart';
import '../../../core/app_colors.dart';
import '../../providers/auth_provider.dart';

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
        title: const Text("Profile", style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Header
          Center(
            child: Column(
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
                const SizedBox(height: 16),
                Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Settings Group
          _buildSectionHeader("Account"),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: LucideIcons.user,
            title: "Personal Information",
            onTap: () => _showPersonalInfo(context, name, email),
          ),
          _buildSettingTile(
            icon: LucideIcons.bell,
            title: "Notifications",
            onTap: () => _showNotificationsDialog(context),
          ),
          
          const SizedBox(height: 32),
          
          _buildSectionHeader("Support"),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: LucideIcons.helpCircle,
            title: "Help Center",
            onTap: () => context.push('/policy', extra: {'title': 'Help Center', 'content': _dummyHelpContent}),
          ),
          _buildSettingTile(
            icon: LucideIcons.shield,
            title: "Privacy Policy",
            onTap: () => context.push('/policy', extra: {'title': 'Privacy Policy', 'content': PolicyScreen.dummyPrivacy}),
          ),
          
          const SizedBox(height: 40),
          
          // Logout Button
          ElevatedButton(
            onPressed: () => _showLogoutDialog(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.danger,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.danger.withOpacity(0.2)),
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
            style: TextButton.styleFrom(foregroundColor: AppColors.textTertiary),
            child: const Text("Delete Account", style: TextStyle(fontSize: 14, decoration: TextDecoration.underline)),
          ),
          
          const SizedBox(height: 40),
          const Center(
            child: Text("UniMateX v1.0.0", style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textMain)),
        trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textTertiary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showPersonalInfo(BuildContext context, String name, String email) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Personal Information", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
            const SizedBox(height: 24),
            _buildInfoRow(LucideIcons.user, "Full Name", name),
            const SizedBox(height: 16),
            _buildInfoRow(LucideIcons.mail, "Email Address", email),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMain)),
          ],
        ),
      ],
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Notifications"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text("Class Reminders"),
                value: true,
                onChanged: (v) {},
                activeColor: AppColors.primary,
              ),
              SwitchListTile(
                title: const Text("Task Deadlines"),
                value: true,
                onChanged: (v) {},
                activeColor: AppColors.primary,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Done")),
          ],
        ),
      ),
    );
  }

  String get _dummyHelpContent => """
How can we help you?

1. How to add a class?
Go to the Timetable tab and click the '+' button in the top right corner. Fill in the subject, room, and time details.

2. Tracking attendance?
In the Attendance tab, you can mark 'Present' or 'Absent' for each subject. The app will automatically calculate your attendance percentage.

3. Managing assignments?
Use the Tasks tab to add upcoming assignments. You can mark them as completed to keep track of your progress.

4. Study Notes?
The Notes tab allows you to write down important points from your lectures. You can edit them anytime.

Still have questions? Contact us at support@unimatex.app
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
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              Navigator.pop(ctx);
              context.go('/login');
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
        content: const Text("This action is permanent and cannot be undone. All your data will be lost."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(authServiceProvider).deleteAccount();
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: const Text("Delete", style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
