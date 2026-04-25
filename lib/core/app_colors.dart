import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xff006666);
  static const Color primaryLight = Color(0xff008080);
  static const Color primaryDark = Color(0xff004d4d);
  static const Color accentTeal = Color(0xff006666);
  static const Color accentTealLight = Color(0xff008080);

  // Neutral colors
  static const Color background = Color(0xfff5f7fb);
  static const Color surface = Color(0xffffffff);
  static const Color textMain = Color(0xff1f2937);
  static const Color textSecondary = Color(0xff6b7280);
  static const Color textTertiary = Color(0xff9ca3af);

  // Status colors
  static const Color success = Color(0xff22c55e);
  static const Color warning = Color(0xfffacc15);
  static const Color danger = Color(0xffef4444);

  // Border & Divider
  static const Color border = Color(0xffe5e7eb);
  static const Color divider = Color(0xfff3f4f6);

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Specific Tailwind Colors for Gradients
  static const Color green50 = Color(0xfff0fdf4);
  static const Color green200 = Color(0xffbbf7d0);
  static const Color green400 = Color(0xff4ade80);
  static const Color green500 = Color(0xff22c55e);
  static const Color green700 = Color(0xff15803d);
  static const Color emerald50 = Color(0xffecfdf5);
  static const Color emerald500 = Color(0xff10b981);

  static const Color amber50 = Color(0xfffffbeb);
  static const Color yellow50 = Color(0xfffefce8);
  static const Color amber100 = Color(0xfffef3c7);
  static const Color amber200 = Color(0xfffde68a);
  static const Color amber400 = Color(0xfffbbf24);
  static const Color yellow500 = Color(0xffeab308);
  static const Color amber600 = Color(0xffd97706);

  static const Color red50 = Color(0xfffef2f2);
  static const Color red100 = Color(0xfffee2e2);
  static const Color red400 = Color(0xfff87171);
  static const Color rose50 = Color(0xfffff1f2);
  static const Color rose500 = Color(0xfff43f5e);

  static const Color blue50 = Color(0xffeff6ff);
  static const Color blue100 = Color(0xffdbeafe);
  static const Color blue200 = Color(0xffbfdbfe);
  static const Color blue600 = Color(0xff2563eb);
  static const Color blue700 = Color(0xff1d4ed8);
  
  static const Color indigo50 = Color(0xffeef2ff);
  static const Color indigo600 = Color(0xff4f46e5);

  static const Color purple50 = Color(0xfffaf5ff);
  static const Color purple100 = Color(0xfff3e8ff);
  static const Color purple200 = Color(0xffe9d5ff);
  static const Color purple500 = Color(0xffa855f7);
  static const Color purple600 = Color(0xff9333ea);
  static const Color purple700 = Color(0xff7e22ce);
  static const Color violet50 = Color(0xfff5f3ff);
  static const Color violet600 = Color(0xff7c3aed);

  static const Color orange50 = Color(0xfffff7ed);
  static const Color orange200 = Color(0xfffed7aa);
  static const Color orange500 = Color(0xfff97316);
  static const Color orange700 = Color(0xffc2410c);

  static const Color pink50 = Color(0xfffdf2f8);
  static const Color pink200 = Color(0xfffbcfe8);
  static const Color pink700 = Color(0xffbe185d);
}
