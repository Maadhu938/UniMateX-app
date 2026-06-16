import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
        child: MarkdownBody(
          data: content,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textSecondary),
            h1: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain),
            h2: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
            h3: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
            listBullet: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  static String get dummyTC => """
**Terms and Conditions for UniMateX**

Last Updated: April 2026

**1. Acceptance of Terms**
By accessing and using UniMateX, you accept and agree to be bound by the terms and provision of this agreement.

**2. Description of Service**
UniMateX is a productivity application designed for students to manage timetables, attendance, notes, and assignments. We provide cloud synchronization via Firebase to keep your data safe and accessible across devices.

**3. User Conduct and Responsibilities**
- You must provide accurate information when creating an account.
- You are solely responsible for maintaining the confidentiality of your login credentials.
- You agree not to use the app for any unlawful purposes or to distribute malicious code.

**4. Intellectual Property**
All content, features, and functionality of UniMateX (including but not limited to UI design, logos, and software) are owned by UniMateX and are protected by international copyright laws.

**5. Third-Party Services**
UniMateX utilizes third-party services such as Google Firebase for cloud storage and synchronization. Your interaction with these services is governed by their respective Privacy Policies and Terms of Service.

**6. Termination**
We reserve the right to suspend or terminate your account at our discretion if you violate any of these Terms.

**7. Limitation of Liability**
In no event shall UniMateX or its developers be liable for any indirect, incidental, special, consequential or punitive damages, including loss of data or academic standing, resulting from your use of the app.

**8. Changes to Terms**
We reserve the right to modify these terms at any time. Your continued use of the app following any changes constitutes acceptance of those changes.
""";

  static String get dummyPrivacy => privacyPolicy;

  static String get privacyPolicy => """
# Privacy Policy

**Last updated: June 2026**

UniMateX ("we", "our", or "the app") is committed to protecting your privacy. This policy explains what information we collect, how we use it, and the choices you have. By using UniMateX you agree to this policy.

## Information We Collect
- **Account information**: When you sign up with email or Google Sign-In, we collect your email address and display name through Firebase Authentication. If you sign in with Google, we receive your basic Google profile (name, email, profile photo).
- **Academic data you create**: Your subjects, attendance records, class timetable, assignments, and notes. You enter this data yourself; we do not collect it from third parties.
- **On-device data**: A local cache of your data is stored on your device to make the app fast and available offline.

We do **not** collect your contacts, location, photos, or browsing activity, and we do **not** sell your data to anyone.

## How We Use Your Information
- To provide the core features: tracking attendance, timetable, assignments, and notes.
- To synchronize your data securely across your devices.
- To send you local reminders (for example, before a class or an assignment deadline) if you enable notifications.
- To maintain, secure, and improve the app.

## Data Storage and Security
Your account and academic data are stored in Google Firebase (Authentication and Cloud Firestore). Data is transmitted over encrypted connections (HTTPS/TLS) and protected by security rules that restrict access to your own account only. Firebase processes data in accordance with Google's privacy and security standards.

## Third-Party Services
We rely on the following providers solely to operate the app:
- **Google Firebase** (Authentication, Cloud Firestore) — data storage and sign-in.
- **Google Sign-In** — optional login method.

Their handling of data is governed by Google's Privacy Policy.

## Notifications
With your permission, UniMateX schedules local reminders on your device. These are generated on-device and are not used for advertising. You can turn reminders off any time in Profile, or in your device's notification settings.

## Data Retention and Deletion
Your data is retained while your account is active. You can permanently delete your account and all associated data at any time from **Profile → Delete Account**. This removes your academic data from our cloud database and clears the local cache on your device. Account deletion is irreversible.

## Children's Privacy
UniMateX is intended for students and general academic use. It is not directed at children under the age required by your local laws to consent to data processing. If you believe a child has provided us personal data, contact us so we can remove it.

## Changes to This Policy
We may update this policy from time to time. Material changes will be reflected by the "Last updated" date above. Continued use of the app after changes means you accept the updated policy.

## Contact
For privacy questions or data requests, contact us at: **support@unimatex.app**

_Replace this address with your real support email before publishing._
""";
}
