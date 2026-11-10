import 'package:flutter/material.dart';

class WritingStatsBar extends StatelessWidget {
  final int wordCount;
  final int charCount;
  final int readingTimeMinutes;
  final int equationCount;

  const WritingStatsBar({
    super.key,
    required this.wordCount,
    required this.charCount,
    required this.readingTimeMinutes,
    required this.equationCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(icon: '📝', value: '$wordCount', label: 'Words'),
          _StatItem(icon: '🔤', value: '$charCount', label: 'Chars'),
          _StatItem(icon: '⏱️', value: '${readingTimeMinutes}m', label: 'Read Time'),
          _StatItem(icon: '📐', value: '$equationCount', label: 'Math Eqn'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4A2E2B)),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
