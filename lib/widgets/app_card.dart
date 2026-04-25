import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;
  final BoxBorder? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: border,
        boxShadow: AppColors.softShadow,
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}
