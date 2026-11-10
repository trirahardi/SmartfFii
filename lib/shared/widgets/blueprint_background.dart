import 'package:flutter/material.dart';
import '../../core/theme/neo_colors.dart';

/// Background bergaya blueprint Neobrutalism dengan pola grid 24x24 px
class BlueprintBackground extends StatelessWidget {
  final Widget child;

  const BlueprintBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? NeoColors.bgDark : NeoColors.bgLight;
    final gridColor = isDark
        ? const Color(0x1AFFFFFF) // Grid putih tipis pada dark
        : const Color(0x4DFFFFFF); // Grid putih tipis pada light

    return Container(
      color: bgColor,
      child: CustomPaint(
        painter: _GridPainter(gridColor: gridColor, step: 24.0),
        child: child,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color gridColor;
  final double step;

  _GridPainter({required this.gridColor, required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    // Garis vertikal
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Garis horizontal
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.gridColor != gridColor || oldDelegate.step != step;
  }
}

