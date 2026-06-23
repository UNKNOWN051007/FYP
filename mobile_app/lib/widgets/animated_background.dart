import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class _Particle {
  double x;
  double y;
  final double radius;
  final double opacity;
  final double speedX;
  final double speedY;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
    required this.speedX,
    required this.speedY,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color glowColor;
  final double time;

  _ParticlePainter({
    required this.particles,
    required this.glowColor,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = glowColor.withValues(alpha: p.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
      // Inner bright core
      final corePaint = Paint()
        ..color = glowColor.withValues(alpha: p.opacity * 0.8);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius * 0.4,
        corePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final WageColors colors;

  const AnimatedBackground({
    super.key,
    required this.child,
    required this.colors,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late final AnimationController _gradientCtrl;
  late final AnimationController _particleCtrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    // Gradient shift: 10s repeat reverse
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Particle drift: continuous ticker
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _particles = _buildParticles();
  }

  List<_Particle> _buildParticles() {
    final rng = math.Random(42);
    return List.generate(10, (_) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 3 + rng.nextDouble() * 4, // 3–7 px
        opacity: 0.15 + rng.nextDouble() * 0.25,
        speedX: (rng.nextDouble() - 0.5) * 0.00012,
        speedY: (rng.nextDouble() - 0.5) * 0.00012,
      );
    });
  }

  void _updateParticles() {
    for (final p in _particles) {
      p.x += p.speedX;
      p.y += p.speedY;
      if (p.x < 0) p.x += 1;
      if (p.x > 1) p.x -= 1;
      if (p.y < 0) p.y += 1;
      if (p.y > 1) p.y -= 1;
    }
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    return AnimatedBuilder(
      animation: Listenable.merge([_gradientCtrl, _particleCtrl]),
      builder: (context, _) {
        _updateParticles();
        final t = _gradientCtrl.value;
        final bgTop = Color.lerp(c.bg, c.card, t * 0.3)!;
        final bgBottom = Color.lerp(c.card, c.bg, t * 0.2)!;

        return Stack(
          children: [
            // Gradient background
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [bgTop, bgBottom],
                  ),
                ),
              ),
            ),
            // Particle layer
            Positioned.fill(
              child: CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  glowColor: c.accent,
                  time: _particleCtrl.value,
                ),
              ),
            ),
            // Content
            widget.child,
          ],
        );
      },
    );
  }
}
