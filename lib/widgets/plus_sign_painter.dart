import 'package:flutter/material.dart';

/// Decorative painter that draws a grid of plus signs
/// Used in login, register, and jobseeker registration pages
class PlusSignPainter extends CustomPainter {
  final double opacity;
  final double spacing;
  final double plusSize;
  final double padding;

  const PlusSignPainter({
    this.opacity = 0.12,
    this.spacing = 40.0,
    this.plusSize = 20.0,
    this.padding = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.5;

    for (double x = padding; x < size.width - padding + spacing; x += spacing) {
      for (double y = padding; y < size.height - padding; y += spacing) {
        // Horizontal line of plus
        canvas.drawLine(
          Offset(x - plusSize / 2, y),
          Offset(x + plusSize / 2, y),
          paint,
        );
        // Vertical line of plus
        canvas.drawLine(
          Offset(x, y - plusSize / 2),
          Offset(x, y + plusSize / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PlusSignPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.spacing != spacing ||
        oldDelegate.plusSize != plusSize ||
        oldDelegate.padding != padding;
  }
}