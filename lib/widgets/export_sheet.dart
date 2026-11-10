import 'package:flutter/material.dart';
import '../models/memories_data.dart';
import '../services/export_service.dart';

class ExportSheet extends StatelessWidget {
  final MemoryEntry entry;

  const ExportSheet({super.key, required this.entry});

  Future<void> _export(BuildContext context, ExportFormat format) async {
    Navigator.pop(context); // Close sheet
    final result = await ExportService.saveAs(entry, format);
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✓ $result')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Save As... (Export Entry)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4A2E2B)),
          ),
          const SizedBox(height: 8),
          Text(
            'Exporting "${entry.title.isEmpty ? 'Untitled' : entry.title}"',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          _ExportOption(
            icon: Icons.code,
            title: 'Markdown File (.md)',
            subtitle: 'Best for Obsidian, Notion, or simple text sharing.',
            onTap: () => _export(context, ExportFormat.markdown),
          ),
          _ExportOption(
            icon: Icons.language,
            title: 'Styled Webpage (.html)',
            subtitle: 'Beautifully styled document you can open in any browser.',
            onTap: () => _export(context, ExportFormat.html),
          ),
          _ExportOption(
            icon: Icons.data_object,
            title: 'Raw Data (.json)',
            subtitle: 'Export raw entry attributes and structure.',
            onTap: () => _export(context, ExportFormat.json),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFFDFB),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFD4C9BD)),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF8C4A32)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.download, size: 20, color: Color(0xFF8C4A32)),
        onTap: onTap,
      ),
    );
  }
}
