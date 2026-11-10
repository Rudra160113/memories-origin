import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';

import '../models/memories_data.dart';

enum ExportFormat { markdown, html, json }

class ExportService {
  static Future<String?> saveAs(MemoryEntry entry, ExportFormat format) async {
    String fileName;
    String content;
    String mimeType;

    // Sanitize title for filename
    final safeTitle = entry.title.isEmpty
        ? 'Untitled_Diary'
        : entry.title.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

    switch (format) {
      case ExportFormat.markdown:
        fileName = '$safeTitle.md';
        mimeType = 'text/markdown';
        content = _generateMarkdown(entry);
        break;
      case ExportFormat.html:
        fileName = '$safeTitle.html';
        mimeType = 'text/html';
        content = _generateHtml(entry);
        break;
      case ExportFormat.json:
        fileName = '$safeTitle.json';
        mimeType = 'application/json';
        content = jsonEncode(entry.toJson());
        break;
    }

    final bytes = utf8.encode(content);
    final file = XFile.fromData(Uint8List.fromList(bytes), mimeType: mimeType, name: fileName);

    try {
      if (kIsWeb) {
        // file_selector handles Web anchor downloads automatically when calling saveTo
        await file.saveTo(fileName);
        return 'Downloaded $fileName successfully.';
      } else {
        // Native Save As Dialog
        final FileSaveLocation? location = await getSaveLocation(
          suggestedName: fileName,
        );

        if (location != null) {
          await file.saveTo(location.path);
          return 'Saved to ${location.path}';
        }
        return null; // User canceled
      }
    } catch (e) {
      return 'Export failed: $e';
    }
  }

  static String _generateMarkdown(MemoryEntry entry) {
    return '''# ${entry.title.isEmpty ? 'Untitled Diary' : entry.title}

**Date:** ${entry.timestamp.toString().split('.')[0]}
**Mood:** ${entry.mood.emoji} ${entry.mood.label}
**Folder:** ${entry.category}

---

${entry.content}

---
*Created by Origin • Memories Offline Journal*
''';
  }

  static String _generateHtml(MemoryEntry entry) {
    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>${entry.title.isEmpty ? 'Untitled Diary' : entry.title}</title>
  <style>
    body { font-family: 'Georgia', serif; background-color: #FAF7F2; color: #4A2E2B; padding: 40px; line-height: 1.6; max-width: 800px; margin: 0 auto; }
    .card { background-color: #FFFDFB; border-radius: 12px; padding: 40px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); }
    h1 { color: #8C4A32; font-size: 2.2em; margin-bottom: 10px; }
    .meta { font-size: 0.95em; color: #888; margin-bottom: 24px; }
    .badge { background: #F4EFEA; color: #8C4A32; padding: 6px 12px; border-radius: 12px; font-weight: bold; display: inline-block; margin-bottom: 16px; border: 1px solid #D4C9BD; }
    p { font-size: 1.1em; white-space: pre-wrap; }
    footer { margin-top: 50px; font-size: 0.85em; color: #B5A89B; text-align: center; font-style: italic; }
  </style>
</head>
<body>
  <div class="card">
    <div class="badge">${entry.mood.emoji} ${entry.mood.label}</div>
    <h1>${entry.title.isEmpty ? 'Untitled Diary' : entry.title}</h1>
    <div class="meta">Date: ${entry.timestamp.toString().split('.')[0]} • Folder: ${entry.category}</div>
    <hr style="border: none; border-top: 1px solid #D4C9BD; margin-bottom: 24px;" />
    <p>${entry.content}</p>
    <footer>Created by Origin • Memories Offline Diary</footer>
  </div>
</body>
</html>''';
  }
}
