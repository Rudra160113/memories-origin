import 'dart:math';
import 'package:flutter/material.dart';

import '../services/thought_service.dart';

class MemoryOrb {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  Color color;
  double opacity;
  double pulsePhase;

  MemoryOrb({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
    required this.opacity,
    required this.pulsePhase,
  });
}

class SplashScreen extends StatefulWidget {
  final VoidCallback onEnterJournal;

  const SplashScreen({super.key, required this.onEnterJournal});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final List<MemoryOrb> _orbs = [];
  Offset? _touchPos;
  double _rippleRadius = 0;

  @override
  void initState() {
    super.initState();
    final random = Random();
    final colors = [
      const Color(0xFFE07A5F),
      const Color(0xFFF4B942),
      const Color(0xFF81B29A),
      const Color(0xFF6D9DC5),
      const Color(0xFFD4A373),
      const Color(0xFFB7094C),
    ];

    for (int i = 0; i < 40; i++) {
      _orbs.add(MemoryOrb(
        x: random.nextDouble() * 500,
        y: random.nextDouble() * 900,
        vx: (random.nextDouble() - 0.5) * 1.5,
        vy: (random.nextDouble() - 0.5) * 1.5,
        radius: random.nextDouble() * 10 + 4,
        color: colors[random.nextInt(colors.length)],
        opacity: random.nextDouble() * 0.5 + 0.3,
        pulsePhase: random.nextDouble() * pi * 2,
      ));
    }

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateOrbs)..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _updateOrbs() {
    final size = MediaQuery.of(context).size;
    for (var orb in _orbs) {
      orb.x += orb.vx;
      orb.y += orb.vy;
      orb.pulsePhase += 0.05;

      if (orb.x < 0 || orb.x > size.width) orb.vx *= -1;
      if (orb.y < 0 || orb.y > size.height) orb.vy *= -1;

      if (_touchPos != null) {
        double dx = orb.x - _touchPos!.dx;
        double dy = orb.y - _touchPos!.dy;
        double dist = sqrt(dx * dx + dy * dy);
        if (dist < 180 && dist > 1) {
          orb.vx += (dx / dist) * 0.5;
          orb.vy += (dy / dist) * 0.5;
        }
      }
    }
    if (_rippleRadius > 0) {
      _rippleRadius += 4;
      if (_rippleRadius > 250) _rippleRadius = 0;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayThought = ThoughtService.getThoughtForDate(DateTime.now());

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _touchPos = details.localPosition;
          });
        },
        onTapDown: (details) {
          setState(() {
            _touchPos = details.localPosition;
            _rippleRadius = 10;
          });
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFBF8F3),
                Color(0xFFF4ECE1),
                Color(0xFFE8DCCB),
                Color(0xFFD8C8B4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Glowing Orbs & Ripple Canvas
              CustomPaint(
                size: Size.infinite,
                painter: GlowingOrbPainter(_orbs, _touchPos, _rippleRadius),
              ),

              // Main Content Box
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glassmorphism Journal Card
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 440),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDFB).withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: const Color(0xFFD4A373).withValues(alpha: 0.5),
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8C4A32).withValues(alpha: 0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Sparkling Book Icon Badge
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFAF0E6), Color(0xFFF3E4D4)],
                                  ),
                                  border: Border.all(color: const Color(0xFFE07A5F).withValues(alpha: 0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE07A5F).withValues(alpha: 0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: const Text('✨📖✨', style: TextStyle(fontSize: 38)),
                              ),
                              const SizedBox(height: 20),

                              // Title "Memories"
                              const Text(
                                'Memories',
                                style: TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3A2321),
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 2,
                                width: 80,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF8C4A32), Color(0xFFF4B942)],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Subtitle
                              const Text(
                                'Your Private Sanctuary for Thoughts,\nMoods & Research Discovery',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Color(0xFF8C4A32),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Creator Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4EFEA),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFD4C9BD)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.star, size: 12, color: Color(0xFFF4B942)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Crafted by Origin',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6E6259),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Daily Thought Preview Pill on Splash
                      Container(
                        constraints: const BoxConstraints(maxWidth: 440),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDFB).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD4C9BD)),
                        ),
                        child: Row(
                          children: [
                            const Text('💡 ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                '"${todayThought.thought}" — ${todayThought.author}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF4A2E2B),
                                  fontFamily: 'Serif',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Glowing Premium "Open Journal" Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8C4A32), Color(0xFFE07A5F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8C4A32).withValues(alpha: 0.45),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: widget.onEnterJournal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Open Journal',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlowingOrbPainter extends CustomPainter {
  final List<MemoryOrb> orbs;
  final Offset? touchPos;
  final double rippleRadius;

  GlowingOrbPainter(this.orbs, this.touchPos, this.rippleRadius);

  @override
  void paint(Canvas canvas, Size size) {
    for (var orb in orbs) {
      final pulsedRadius = orb.radius + sin(orb.pulsePhase) * 2;

      // Glow halo
      final haloPaint = Paint()
        ..color = orb.color.withValues(alpha: (orb.opacity * 0.25).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(orb.x, orb.y), pulsedRadius * 2, haloPaint);

      // Core orb
      final corePaint = Paint()..color = orb.color.withValues(alpha: orb.opacity);
      canvas.drawCircle(Offset(orb.x, orb.y), pulsedRadius, corePaint);
    }

    if (touchPos != null && rippleRadius > 0) {
      final ripplePaint = Paint()
        ..color = const Color(0xFFE07A5F).withValues(alpha: (1 - (rippleRadius / 250)).clamp(0.0, 0.4))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(touchPos!, rippleRadius, ripplePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
