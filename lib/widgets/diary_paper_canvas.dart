import 'package:flutter/material.dart';

enum PaperStyle {
  ruled('Classic Ruled', Color(0xFFCDBBAA)),
  grid('Vintage Grid', Color(0xFFD8C8B8)),
  dots('Bullet Dot Grid', Color(0xFFC5B4A4)),
  clean('Minimal Linen', Color(0xFFE2D6C8));

  final String label;
  final Color lineColor;
  const PaperStyle(this.label, this.lineColor);
}

class LinedPaperPainter extends CustomPainter {
  final double lineHeight;
  final Color lineColor;
  final PaperStyle style;

  LinedPaperPainter({
    required this.lineHeight,
    required this.lineColor,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    if (style == PaperStyle.ruled || style == PaperStyle.clean) {
      // Draw horizontal ruled lines
      double y = lineHeight;
      while (y < size.height) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        y += lineHeight;
      }
    } else if (style == PaperStyle.grid) {
      // Draw grid lines
      double y = lineHeight;
      while (y < size.height) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        y += lineHeight;
      }
      double x = lineHeight;
      while (x < size.width) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        x += lineHeight;
      }
    } else if (style == PaperStyle.dots) {
      // Draw dot grid
      final dotPaint = Paint()..color = lineColor.withValues(alpha: 0.7);
      double y = lineHeight;
      while (y < size.height) {
        double x = lineHeight;
        while (x < size.width) {
          canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
          x += lineHeight;
        }
        y += lineHeight;
      }
    }
  }

  @override
  bool shouldRepaint(covariant LinedPaperPainter oldDelegate) {
    return oldDelegate.lineHeight != lineHeight || oldDelegate.lineColor != lineColor || oldDelegate.style != style;
  }
}
