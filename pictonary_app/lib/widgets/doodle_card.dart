import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Card avec effet dessiné à la main style Doodle Jump
class DoodleCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const DoodleCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8.0),
      child: CustomPaint(
        painter: HandDrawnCardPainter(
          color: color ?? const Color(0xFFECF0F1),
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

class HandDrawnCardPainter extends CustomPainter {
  final Color color;

  HandDrawnCardPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2C3E50)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Créer un rectangle avec des coins arrondis irréguliers
    final path = _createHandDrawnRectangle(size);

    // Ombre
    final shadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawPath(
      path.shift(const Offset(2, 4)),
      shadowPaint,
    );

    // Remplissage
    canvas.drawPath(path, paint);
    
    // Bordure dessinée à la main
    canvas.drawPath(path, borderPaint);
  }

  Path _createHandDrawnRectangle(Size size) {
    final path = Path();
    final radius = 12.0;
    final random = math.Random(42); // Seed fixe pour consistance
    
    // Fonction pour ajouter une petite variation
    double wiggle() => (random.nextDouble() - 0.5) * 1.5;
    
    // Commencer en haut à gauche
    path.moveTo(radius + wiggle(), wiggle());
    
    // Ligne du haut (avec petites variations)
    final topSteps = 5;
    for (int i = 0; i <= topSteps; i++) {
      final x = (size.width - radius) * i / topSteps + radius;
      path.lineTo(x + wiggle(), wiggle());
    }
    
    // Coin haut-droit
    path.quadraticBezierTo(
      size.width + wiggle(), wiggle(),
      size.width + wiggle(), radius + wiggle(),
    );
    
    // Ligne droite
    final rightSteps = 5;
    for (int i = 0; i <= rightSteps; i++) {
      final y = (size.height - radius) * i / rightSteps + radius;
      path.lineTo(size.width + wiggle(), y + wiggle());
    }
    
    // Coin bas-droit
    path.quadraticBezierTo(
      size.width + wiggle(), size.height + wiggle(),
      size.width - radius + wiggle(), size.height + wiggle(),
    );
    
    // Ligne du bas
    final bottomSteps = 5;
    for (int i = bottomSteps; i >= 0; i--) {
      final x = (size.width - radius) * i / bottomSteps + radius;
      path.lineTo(x + wiggle(), size.height + wiggle());
    }
    
    // Coin bas-gauche
    path.quadraticBezierTo(
      wiggle(), size.height + wiggle(),
      wiggle(), size.height - radius + wiggle(),
    );
    
    // Ligne gauche
    final leftSteps = 5;
    for (int i = leftSteps; i >= 0; i--) {
      final y = (size.height - radius) * i / leftSteps + radius;
      path.lineTo(wiggle(), y + wiggle());
    }
    
    // Coin haut-gauche
    path.quadraticBezierTo(
      wiggle(), wiggle(),
      radius + wiggle(), wiggle(),
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
