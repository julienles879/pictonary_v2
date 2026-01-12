import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Fond style calepin/carnet de notes avec spirale
class NotebookBackground extends StatelessWidget {
  final Widget child;
  final bool showSpiral;
  final bool showLines;

  const NotebookBackground({
    super.key,
    required this.child,
    this.showSpiral = true,
    this.showLines = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond papier beige
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFDF5), // Blanc cassé
                Color(0xFFFFF8E7), // Beige très clair
              ],
            ),
          ),
        ),
        // Lignes du calepin
        if (showLines)
          CustomPaint(
            painter: NotebookLinesPainter(),
            size: Size.infinite,
          ),
        // Contenu sans padding pour la spirale
        child,
      ],
    );
  }
}

class NotebookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8D4E8).withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const lineSpacing = 32.0;
    
    // Dessiner des lignes horizontales espacées
    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      // Petite variation pour l'effet dessiné à la main
      final startX = 50.0 + (math.Random(y.toInt()).nextDouble() - 0.5) * 2;
      final endX = size.width - 16 + (math.Random(y.toInt() + 1).nextDouble() - 0.5) * 2;
      
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpiralPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final spiralPaint = Paint()
      ..color = const Color(0xFF95A5A6)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final holePaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.fill;

    final holeOutlinePaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const holeRadius = 8.0;
    const holeSpacing = 40.0;
    const spiralX = 20.0;

    // Dessiner les trous de la spirale
    for (double y = holeSpacing; y < size.height; y += holeSpacing) {
      // Trou central
      canvas.drawCircle(
        Offset(spiralX, y),
        holeRadius,
        Paint()..color = Colors.white,
      );
      
      // Ombre du trou
      canvas.drawCircle(
        Offset(spiralX + 1, y + 1),
        holeRadius - 1,
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      
      // Intérieur noir du trou
      canvas.drawCircle(
        Offset(spiralX, y),
        holeRadius - 2,
        holePaint,
      );
      
      // Contour du trou
      canvas.drawCircle(
        Offset(spiralX, y),
        holeRadius,
        holeOutlinePaint,
      );
      
      // Anneaux métalliques de la spirale
      if (y > holeSpacing && y < size.height - holeSpacing) {
        // Arc supérieur
        canvas.drawArc(
          Rect.fromCircle(center: Offset(spiralX, y - holeSpacing / 2), radius: 12),
          math.pi * 0.2,
          math.pi * 0.6,
          false,
          spiralPaint,
        );
        
        // Arc inférieur
        canvas.drawArc(
          Rect.fromCircle(center: Offset(spiralX, y - holeSpacing / 2), radius: 12),
          math.pi * 1.2,
          math.pi * 0.6,
          false,
          spiralPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
