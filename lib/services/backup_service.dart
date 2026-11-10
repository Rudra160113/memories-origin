import 'dart:convert';
import '../models/memories_data.dart';

class BackupService {
  static String exportToJson(List<MemoryEntry> entries) {
    final list = entries.map((e) => e.toJson()).toList();
    return jsonEncode({
      'version': '1.0.0',
      'app': 'Memories by Origin',
      'timestamp': DateTime.now().toIso8601String(),
      'entries': list,
    });
  }

  static List<MemoryEntry> importFromJson(String jsonStr) {
    final data = jsonDecode(jsonStr);
    final List list = data['entries'] ?? [];
    return list.map((e) => MemoryEntry.fromJson(e)).toList();
  }
}
