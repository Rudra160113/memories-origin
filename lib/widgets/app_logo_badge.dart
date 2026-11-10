import 'package:flutter/material.dart';

class AppLogoBadge extends StatelessWidget {
  final double size;

  const AppLogoBadge({super.key, this.size = 48.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: const RadialGradient(
          center: Alignment.center,
          radius: 0.95,
          colors: [
            Color(0xFF2E1C4D),
            Color(0xFF140D26),
            Color(0xFF0A0614),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D4EDD).withValues(alpha: 0.4),
            blurRadius: size * 0.3,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFF3A86FF).withValues(alpha: 0.3),
            blurRadius: size * 0.2,
          )
        ],
        border: Border.all(
          color: const Color(0xFFC77DFF).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF7209B7),
              Color(0xFF4895EF),
              Color(0xFF4CC9F0),
              Color(0xFFF72585),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ).createShader(bounds),
          child: Text(
            'M',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: size * 0.65,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
