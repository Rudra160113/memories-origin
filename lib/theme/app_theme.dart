import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final Color backgroundColor;
  final Color cardColor;
  final Color primaryColor;
  final Color textColor;
  final Color subtextColor;
  final Color accentColor;

  AppTheme({
    required this.name,
    required this.backgroundColor,
    required this.cardColor,
    required this.primaryColor,
    required this.textColor,
    required this.subtextColor,
    required this.accentColor,
  });

  static List<AppTheme> get themes => [
        AppTheme(
          name: 'Warm Parchment',
          backgroundColor: const Color(0xFFFAF7F2),
          cardColor: const Color(0xFFFFFDFB),
          primaryColor: const Color(0xFF8C4A32),
          textColor: const Color(0xFF4A2E2B),
          subtextColor: const Color(0xFF8C4A32),
          accentColor: const Color(0xFFE07A5F),
        ),
        AppTheme(
          name: 'Midnight Espresso',
          backgroundColor: const Color(0xFF1B1917),
          cardColor: const Color(0xFF262320),
          primaryColor: const Color(0xFFD4A373),
          textColor: const Color(0xFFF3EFEA),
          subtextColor: const Color(0xFFE07A5F),
          accentColor: const Color(0xFFF4B942),
        ),
        AppTheme(
          name: 'Cherry Blossom',
          backgroundColor: const Color(0xFFFFF0F5),
          cardColor: const Color(0xFFFFFFFF),
          primaryColor: const Color(0xFFB7094C),
          textColor: const Color(0xFF590219),
          subtextColor: const Color(0xFFC77DFF),
          accentColor: const Color(0xFFFF85A1),
        ),
        AppTheme(
          name: 'Botanical Sage',
          backgroundColor: const Color(0xFFF0F4F1),
          cardColor: const Color(0xFFFFFFFF),
          primaryColor: const Color(0xFF2D5A27),
          textColor: const Color(0xFF1A3317),
          subtextColor: const Color(0xFF81B29A),
          accentColor: const Color(0xFF40916C),
        ),
        AppTheme(
          name: 'Obsidian Ink',
          backgroundColor: const Color(0xFF121212),
          cardColor: const Color(0xFF1E1E1E),
          primaryColor: const Color(0xFFBB86FC),
          textColor: const Color(0xFFE1E1E1),
          subtextColor: const Color(0xFF03DAC6),
          accentColor: const Color(0xFFCF6679),
        ),
      ];
}
