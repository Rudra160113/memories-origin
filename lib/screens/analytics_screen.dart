import 'package:flutter/material.dart';

import '../models/memories_data.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<MemoryEntry> entries;
  final VoidCallback onBack;

  const AnalyticsScreen({super.key, required this.entries, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final moodCounts = <MoodType, int>{};
    for (var m in MoodType.values) {
      moodCounts[m] = 0;
    }
    for (var e in entries) {
      moodCounts[e.mood] = (moodCounts[e.mood] ?? 0) + 1;
    }

    final totalEntries = entries.length;
    final bookmarkedCount = entries.where((e) => e.isBookmarked).length;
    final totalWords = entries.fold<int>(0, (sum, e) => sum + e.wordCount);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A2E2B)),
          onPressed: onBack,
        ),
        title: const Text('Mood Analytics & Metrics', style: TextStyle(color: Color(0xFF4A2E2B), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatCard(title: 'Memories Logged', value: '$totalEntries', icon: '📖', color: const Color(0xFF8C4A32)),
                const SizedBox(width: 12),
                _StatCard(title: 'Bookmarked', value: '$bookmarkedCount', icon: '⭐', color: const Color(0xFFF4B942)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(title: 'Total Words', value: '$totalWords', icon: '✍️', color: const Color(0xFF81B29A)),
                const SizedBox(width: 12),
                _StatCard(title: 'Unique Folders', value: '${DefaultCategories.list.length}', icon: '📁', color: const Color(0xFF6D9DC5)),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Emotion & Mood Breakdown',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A2E2B)),
            ),
            const SizedBox(height: 12),
            ...MoodType.values.map((m) {
              final count = moodCounts[m] ?? 0;
              final percent = totalEntries == 0 ? 0.0 : (count / totalEntries);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${m.emoji} ${m.label}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('$count (${(percent * 100).toStringAsFixed(1)}%)', style: TextStyle(fontWeight: FontWeight.bold, color: m.color)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: percent,
                      color: m.color,
                      backgroundColor: m.color.withValues(alpha: 0.15),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDFB),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
