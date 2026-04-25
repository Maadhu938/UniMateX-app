import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class WavePainter extends CustomPainter {
  final Color color;
  final double opacity;

  WavePainter({required this.color, this.opacity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.7,
      size.width * 0.8,
      size.height,
    );
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class LoginBackground extends StatelessWidget {
  final Widget child;
  const LoginBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: CustomPaint(
              painter: WavePainter(color: AppColors.primary.withOpacity(0.1)),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: CustomPaint(
              painter: WavePainter(color: AppColors.primary),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
