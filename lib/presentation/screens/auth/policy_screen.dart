import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/app_colors.dart';

class PolicyScreen extends StatelessWidget {
  final String title;
  final String content;

  const PolicyScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textMain,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          content,
          style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  static String get dummyTC => """
1. Acceptance of Terms
By accessing or using UniMateX, you agree to be bound by these Terms and Conditions.

2. Description of Service
UniMateX provides students with tools to manage attendance, timetables, assignments, and notes.

3. User Responsibilities
You are responsible for maintaining the confidentiality of your account and password.

4. Data Privacy
We value your privacy. Your data is stored securely and used only for the purpose of providing the service.

5. Modifications
We reserve the right to modify or discontinue the service at any time without notice.

6. Limitation of Liability
UniMateX is provided "as is" without any warranty.
""";

  static String get dummyPrivacy => """
1. Information We Collect
We collect information you provide directly to us when you create an account, such as your name and email.

2. How We Use Information
We use the information to provide, maintain, and improve our services.

3. Sharing of Information
We do not share your personal information with third parties except as required by law.

4. Data Security
We take reasonable measures to protect your information from loss, theft, or misuse.

5. Your Choices
You can update your account information at any time through the profile settings.
""";
}
