import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Bouton avec effet dessiné à la main style Doodle Jump
class DoodleButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;
  final bool isPrimary;

  const DoodleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF2ECC71),
    this.icon,
    this.isPrimary = true,
  });

  @override
  State<DoodleButton> createState() => _DoodleButtonState();
}

class _DoodleButtonState extends State<DoodleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: CustomPaint(
          painter: HandDrawnButtonPainter(
            color: widget.color,
            isPressed: _isPressed,
            isPrimary: widget.isPrimary,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.isPrimary ? Colors.white : const Color(0xFF2C3E50),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isPrimary ? Colors.white : const Color(0xFF2C3E50),
                    fontFamily: 'ComicNeue',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HandDrawnButtonPainter extends CustomPainter {
  final Color color;
  final bool isPressed;
  final bool isPrimary;

  HandDrawnButtonPainter({
    required this.color,
    required this.isPressed,
    required this.isPrimary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isPrimary ? color : Colors.white;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2C3E50)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Décalage si pressé
    final offset = isPressed ? 2.0 : 0.0;

    // Créer un rectangle avec des coins arrondis légèrement irréguliers
    final path = Path();
    final radius = 16.0;
    
    // Coin haut-gauche
    path.moveTo(radius + _wiggle(), offset);
    
    // Ligne du haut
    path.lineTo(size.width - radius + _wiggle(), offset + _wiggle());
    
    // Coin haut-droit
    path.quadraticBezierTo(
      size.width + _wiggle(), offset + _wiggle(),
      size.width + _wiggle(), radius + offset + _wiggle(),
    );
    
    // Ligne droite
    path.lineTo(size.width + _wiggle(), size.height - radius + offset + _wiggle());
    
    // Coin bas-droit
    path.quadraticBezierTo(
      size.width + _wiggle(), size.height + offset + _wiggle(),
      size.width - radius + _wiggle(), size.height + offset + _wiggle(),
    );
    
    // Ligne du bas
    path.lineTo(radius + _wiggle(), size.height + offset + _wiggle());
    
    // Coin bas-gauche
    path.quadraticBezierTo(
      _wiggle(), size.height + offset + _wiggle(),
      _wiggle(), size.height - radius + offset + _wiggle(),
    );
    
    // Ligne gauche
    path.lineTo(_wiggle(), radius + offset + _wiggle());
    
    // Retour au début
    path.quadraticBezierTo(
      _wiggle(), offset + _wiggle(),
      radius + _wiggle(), offset,
    );
    
    path.close();

    // Ombre (si non pressé)
    if (!isPressed) {
      final shadowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.black.withOpacity(0.2);
      canvas.drawPath(
        path.shift(const Offset(0, 4)),
        shadowPaint,
      );
    }

    // Remplissage
    canvas.drawPath(path, paint);
    
    // Bordure
    canvas.drawPath(path, borderPaint);
  }

  // Ajoute une petite variation pour l'effet dessiné à la main
  double _wiggle() {
    return (math.Random().nextDouble() - 0.5) * 2;
  }

  @override
  bool shouldRepaint(covariant HandDrawnButtonPainter oldDelegate) {
    return oldDelegate.isPressed != isPressed;
  }
}
