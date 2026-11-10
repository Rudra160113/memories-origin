import 'package:flutter/material.dart';

import 'models/memories_data.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/note_editor_screen.dart';
import 'screens/privacy_audit_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/timeline_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MemoriesApp());
}

class MemoriesApp extends StatefulWidget {
  const MemoriesApp({super.key});

  @override
  State<MemoriesApp> createState() => _MemoriesAppState();
}

class _MemoriesAppState extends State<MemoriesApp> {
  int _screenIndex = 0; // 0: Splash, 1: Timeline, 2: Editor, 3: Settings, 4: Analytics, 5: Privacy, 6: AiChat
  MemoryEntry? _editingEntry;
  MoodType? _selectedMoodFilter;
  AppSettings _settings = AppSettings();

  final List<MemoryEntry> _entries = [
    MemoryEntry(
      id: '1',
      title: 'Reflections on Offline AI & Privacy',
      content:
          'Today I explored running Llama.cpp GGUF models locally on Android via Flutter. The privacy guarantees by Origin ensure zero cloud tracking.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      mood: MoodType.gratitude,
      category: 'Research',
      isBookmarked: true,
      tags: ['AI', 'Journal'],
    ),
    MemoryEntry(
      id: '2',
      title: 'Academic Calculus Study Log',
      content:
          'Calculus homework session completed. Applied integration techniques to solve definite integrals. Verified result via MathJS API connector.',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      mood: MoodType.serenity,
      category: 'Homework',
      tags: ['Math', 'Calculus'],
    ),
    MemoryEntry(
      id: '3',
      title: 'Morning Joy & Weather Check',
      content:
          'A wonderful sunny day. Checked Open-Meteo weather connector and ZenQuotes for morning motivation. Feeling full of energy and creativity.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      mood: MoodType.joy,
      category: 'Personal',
      tags: ['Weather', 'Motivation'],
    ),
  ];

  late List<AiConnector> _connectors;

  @override
  void initState() {
    super.initState();
    _connectors = PreconfiguredConnectors.defaultList;
  }

  void _openAiChat() {
    setState(() {
      _screenIndex = 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = AppTheme.themes.firstWhere(
      (t) => t.name == _settings.themeName,
      orElse: () => AppTheme.themes.first,
    );

    return MaterialApp(
      title: 'Memories (by Origin)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: activeTheme.backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: activeTheme.primaryColor,
          surface: activeTheme.backgroundColor,
        ),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          switch (_screenIndex) {
            case 0:
              return SplashScreen(
                onEnterJournal: () => setState(() => _screenIndex = 1),
              );
            case 1:
              return TimelineScreen(
                entries: _entries,
                onNewEntry: () => setState(() {
                  _editingEntry = null;
                  _screenIndex = 2;
                }),
                onOpenEntry: (entry) => setState(() {
                  _editingEntry = entry;
                  _screenIndex = 2;
                }),
                onOpenSettings: () => setState(() => _screenIndex = 3),
                onOpenAiAssistant: () {
                  _editingEntry = null;
                  _openAiChat();
                },
                onOpenAnalytics: () => setState(() => _screenIndex = 4),
                onOpenPrivacyAudit: () => setState(() => _screenIndex = 5),
                onSelectMoodFilter: (mood) => setState(() => _selectedMoodFilter = mood),
                selectedMoodFilter: _selectedMoodFilter,
                onToggleBookmark: (entry) {
                  setState(() {
                    entry.isBookmarked = !entry.isBookmarked;
                  });
                },
                onDeleteEntry: (entry) {
                  setState(() {
                    _entries.removeWhere((e) => e.id == entry.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Deleted note '${entry.title}'")),
                  );
                },
                onExportEntry: (entry, format) {
                  // Replaced by direct ExportSheet triggers inside the Note Editor
                },
                onUpdateEntryCategory: (entry, newCategory) {
                  setState(() {
                    entry.category = newCategory;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Moved '${entry.title}' to category '$newCategory'")),
                  );
                },
              );
            case 2:
              return NoteEditorScreen(
                initialEntry: _editingEntry,
                onSaveEntry: (saved) {
                  setState(() {
                    final idx = _entries.indexWhere((e) => e.id == saved.id);
                    if (idx >= 0) {
                      _entries[idx] = saved;
                    } else {
                      _entries.insert(0, saved);
                    }
                  });
                },
                onBack: () => setState(() => _screenIndex = 1),
                onOpenAiAssistantWithContent: (title, content) {
                  setState(() {
                    _editingEntry = MemoryEntry(
                      id: _editingEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      content: content,
                      timestamp: _editingEntry?.timestamp ?? DateTime.now(),
                      mood: _editingEntry?.mood ?? MoodType.joy,
                    );
                    final idx = _entries.indexWhere((e) => e.id == _editingEntry!.id);
                    if (idx >= 0) {
                      _entries[idx] = _editingEntry!;
                    } else {
                      _entries.insert(0, _editingEntry!);
                    }
                    _screenIndex = 6;
                  });
                },
              );
            case 3:
              return SettingsScreen(
                connectors: _connectors,
                settings: _settings,
                entries: _entries,
                onToggleConnector: (id, enabled) {
                  setState(() {
                    final idx = _connectors.indexWhere((c) => c.id == id);
                    if (idx >= 0) {
                      _connectors[idx].isEnabled = enabled;
                    }
                  });
                },
                onAddConnector: (newCon) {
                  setState(() {
                    _connectors.add(newCon);
                  });
                },
                onUpdateSettings: (newSettings) {
                  setState(() {
                    _settings = newSettings;
                  });
                },
                onRestoreEntries: (restored) {
                  setState(() {
                    _entries.addAll(restored);
                  });
                },
                onBack: () => setState(() => _screenIndex = 1),
              );
            case 4:
              return AnalyticsScreen(
                entries: _entries,
                onBack: () => setState(() => _screenIndex = 1),
              );
            case 5:
              return PrivacyAuditScreen(
                onBack: () => setState(() => _screenIndex = 1),
              );
            case 6:
              return AiChatScreen(
                entries: _entries,
                connectors: _connectors,
                settings: _settings,
                activeEntry: _editingEntry,
                onBack: () => setState(() => _screenIndex = (_editingEntry != null) ? 2 : 1),
                onReplaceNoteContent: (text) {
                  setState(() {
                    if (_editingEntry != null) {
                      _editingEntry!.content = text;
                    } else {
                      _editingEntry = MemoryEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Ai⁺ Generated Entry',
                        content: text,
                        timestamp: DateTime.now(),
                        mood: MoodType.joy,
                      );
                      _entries.insert(0, _editingEntry!);
                    }
                    _screenIndex = 2;
                  });
                },
                onAppendNoteContent: (text) {
                  setState(() {
                    if (_editingEntry != null) {
                      _editingEntry!.content += text;
                    }
                    _screenIndex = 2;
                  });
                },
              );
            default:
              return SplashScreen(onEnterJournal: () => setState(() => _screenIndex = 1));
          }
        },
      ),
    );
  }
}
