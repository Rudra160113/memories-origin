import 'package:flutter/material.dart';
import '../models/memories_data.dart';

class EmotionPickerDialog extends StatelessWidget {
  final MoodType selectedMood;
  final Function(MoodType) onMoodSelected;

  const EmotionPickerDialog({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFFFAF7F2),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text('✳️', style: TextStyle(fontSize: 22, color: Color(0xFF8C4A32))),
                    SizedBox(width: 8),
                    Text(
                      'Select Emotion for Today',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF4A2E2B),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8C4A32)),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'How are you feeling right now? Tap an emoji to log your daily mood.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: MoodType.values.map((mood) {
                final isSelected = selectedMood == mood;
                return InkWell(
                  onTap: () {
                    onMoodSelected(mood);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? mood.color : const Color(0xFFFFFDFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? mood.color : const Color(0xFFD4C9BD),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: mood.color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected ? Colors.white : const Color(0xFF4A2E2B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
