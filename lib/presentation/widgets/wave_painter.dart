import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// A smooth, layered wave painter with gradient fill.
class WavePainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double phase;

  WavePainter({
    required this.color,
    this.opacity = 1.0,
    this.phase = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(opacity * 0.7),
          color.withOpacity(opacity),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Start from top-left, draw a flowing multi-curve wave
    path.moveTo(0, h * (0.45 + phase * 0.05));

    // First curve: gentle rise
    path.cubicTo(
      w * 0.20, h * (0.25 + phase * 0.08),
      w * 0.35, h * (0.55 - phase * 0.06),
      w * 0.50, h * (0.40 + phase * 0.04),
    );

    // Second curve: dip
    path.cubicTo(
      w * 0.65, h * (0.25 - phase * 0.05),
      w * 0.80, h * (0.50 + phase * 0.07),
      w * 1.00, h * (0.35 - phase * 0.03),
    );

    // Close the shape along the bottom
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.phase != phase;
}

/// A premium login background with layered wave decorations and
/// a subtle top-right accent circle.
class LoginBackground extends StatelessWidget {
  final Widget child;
  const LoginBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: Colors.white,
        child: Stack(
        children: [
          // Back wave layer (lighter, taller)
          Positioned(
            bottom: -10, // Slight bleed to ensure no gaps
            left: 0,
            right: 0,
            height: 140, // Reduced from 160
            child: CustomPaint(
              painter: WavePainter(
                color: AppColors.primary,
                opacity: 0.07,
                phase: 0.5,
              ),
            ),
          ),

          // Middle wave layer
          Positioned(
            bottom: -10,
            left: 0,
            right: 0,
            height: 110, // Reduced from 130
            child: CustomPaint(
              painter: WavePainter(
                color: AppColors.primary,
                opacity: 0.14,
                phase: 0.2,
              ),
            ),
          ),

          // Front wave layer (most opaque, shortest)
          Positioned(
            bottom: -10,
            left: 0,
            right: 0,
            height: 85, // Reduced from 100
            child: CustomPaint(
              painter: WavePainter(
                color: AppColors.primary,
                opacity: 0.22,
                phase: 0.0,
              ),
            ),
          ),

          // Main content
          child,
        ],
      ),
    ),
    );
  }
}
