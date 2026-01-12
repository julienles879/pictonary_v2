import 'package:flutter/material.dart';

/// Fond papier quadrillé style Doodle Jump
class GridPaperBackground extends StatelessWidget {
  final Widget child;
  final Color gridColor;
  final double gridSize;

  const GridPaperBackground({
    super.key,
    required this.child,
    this.gridColor = const Color(0xFFE0E0E0),
    this.gridSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond papier
        Container(
          color: const Color(0xFFFFFDF5),
        ),
        // Grille
        CustomPaint(
          painter: GridPaperPainter(
            gridColor: gridColor,
            gridSize: gridSize,
          ),
          child: Container(),
        ),
        // Contenu
        child,
      ],
    );
  }
}

class GridPaperPainter extends CustomPainter {
  final Color gridColor;
  final double gridSize;

  GridPaperPainter({
    required this.gridColor,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Lignes verticales
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Lignes horizontales
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
