import 'package:flutter/material.dart';
import '../widgets/diary_paper_canvas.dart';

enum MoodType {
  joy('Joy', '✨', Color(0xFFF4B942)),
  serenity('Serenity', '🌿', Color(0xFF81B29A)),
  sadness('Sadness', '💧', Color(0xFF6D9DC5)),
  anger('Anger', '🔥', Color(0xFFE07A5F)),
  anxiety('Anxiety', '⚡', Color(0xFFF2CC8F)),
  gratitude('Gratitude', '🌸', Color(0xFFD4A373)),
  passion('Passion', '❤️', Color(0xFFB7094C));

  final String label;
  final String emoji;
  final Color color;
  const MoodType(this.label, this.emoji, this.color);
}

class DefaultCategories {
  static const List<Map<String, String>> list = [
    {'name': 'Personal', 'icon': '🏠'},
    {'name': 'Homework', 'icon': '📚'},
    {'name': 'Research', 'icon': '🔬'},
    {'name': 'Gratitude Log', 'icon': '🌸'},
    {'name': 'Ideas & Goals', 'icon': '💡'},
    {'name': 'Travel & Notes', 'icon': '✈️'},
  ];
}

class MemoryEntry {
  final String id;
  String title;
  String content;
  final DateTime timestamp;
  MoodType mood;
  String category;
  PaperStyle paperStyle;
  bool isBookmarked;
  List<String> photos;
  List<String> tags;

  MemoryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.mood = MoodType.joy,
    this.category = 'Personal',
    this.paperStyle = PaperStyle.ruled,
    this.isBookmarked = false,
    List<String>? photos,
    List<String>? tags,
  })  : photos = photos ?? [],
        tags = tags ?? [];

  int get wordCount {
    if (content.trim().isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }

  int get readingTimeMinutes {
    return (wordCount / 200).ceil().clamp(1, 60);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'mood': mood.name,
        'category': category,
        'paperStyle': paperStyle.name,
        'isBookmarked': isBookmarked,
        'photos': photos,
        'tags': tags,
      };

  factory MemoryEntry.fromJson(Map<String, dynamic> json) => MemoryEntry(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
        mood: MoodType.values.firstWhere((e) => e.name == json['mood'], orElse: () => MoodType.joy),
        category: json['category'] ?? 'Personal',
        paperStyle: PaperStyle.values.firstWhere((e) => e.name == json['paperStyle'], orElse: () => PaperStyle.ruled),
        isBookmarked: json['isBookmarked'] ?? false,
        photos: List<String>.from(json['photos'] ?? []),
        tags: List<String>.from(json['tags'] ?? []),
      );
}

enum ConnectorCategory { wellBeing, academics, research }

class AiConnector {
  final String id;
  final String name;
  final ConnectorCategory category;
  final String url;
  final String jsonPath;
  bool isEnabled;
  final bool isPreconfigured;

  AiConnector({
    required this.id,
    required this.name,
    required this.category,
    required this.url,
    required this.jsonPath,
    this.isEnabled = true,
    this.isPreconfigured = true,
  });
}

class PreconfiguredConnectors {
  static List<AiConnector> get defaultList => [
        // Well-Being
        AiConnector(id: 'wb_1', name: 'ZenQuotes API', category: ConnectorCategory.wellBeing, url: 'https://zenquotes.io/api/random', jsonPath: 'q'),
        AiConnector(id: 'wb_2', name: 'Advice Slip API', category: ConnectorCategory.wellBeing, url: 'https://api.adviceslip.com/advice', jsonPath: 'advice'),
        AiConnector(id: 'wb_3', name: 'Affirmations.dev', category: ConnectorCategory.wellBeing, url: 'https://affirmations.dev/', jsonPath: 'affirmation'),
        AiConnector(id: 'wb_4', name: 'Open-Meteo Weather', category: ConnectorCategory.wellBeing, url: 'https://api.open-meteo.com/v1/forecast?latitude=28.61&longitude=77.20&current=temperature_2m', jsonPath: 'current.temperature_2m'),
        AiConnector(id: 'wb_5', name: 'World Time API', category: ConnectorCategory.wellBeing, url: 'https://worldtimeapi.org/api/timezone/Etc/UTC', jsonPath: 'datetime'),
        AiConnector(id: 'wb_6', name: 'Bored API', category: ConnectorCategory.wellBeing, url: 'https://bored-api.appbrewery.com/random', jsonPath: 'activity'),
        AiConnector(id: 'wb_7', name: 'Daily Stoic Quotes', category: ConnectorCategory.wellBeing, url: 'https://api.themotivate365.com/stoic-quote', jsonPath: 'quote'),
        AiConnector(id: 'wb_8', name: 'Numbers API', category: ConnectorCategory.wellBeing, url: 'http://numbersapi.com/random/trivia?json', jsonPath: 'text'),

        // Academics
        AiConnector(id: 'ac_1', name: 'Free Dictionary API', category: ConnectorCategory.academics, url: 'https://api.dictionaryapi.dev/api/v2/entries/en/', jsonPath: 'meanings'),
        AiConnector(id: 'ac_2', name: 'Datamuse Linguistic API', category: ConnectorCategory.academics, url: 'https://api.datamuse.com/words?ml=test', jsonPath: 'word'),
        AiConnector(id: 'ac_3', name: 'Wikipedia REST Summary', category: ConnectorCategory.academics, url: 'https://en.wikipedia.org/api/rest_v1/page/summary/', jsonPath: 'extract'),
        AiConnector(id: 'ac_4', name: 'Wiktionary Definition', category: ConnectorCategory.academics, url: 'https://en.wiktionary.org/api/rest_v1/page/definition/', jsonPath: 'definition'),
        AiConnector(id: 'ac_5', name: 'Open Library Books Search', category: ConnectorCategory.academics, url: 'https://openlibrary.org/search.json?q=kotlin', jsonPath: 'docs.title'),

        // Research
        AiConnector(id: 'rs_1', name: 'arXiv Scholarly Preprints', category: ConnectorCategory.research, url: 'https://export.arxiv.org/api/query?search_query=all:quantum&max_results=5', jsonPath: 'entry.title'),
        AiConnector(id: 'rs_2', name: 'Crossref DOI Works', category: ConnectorCategory.research, url: 'https://api.crossref.org/works?query=ai&rows=3', jsonPath: 'message.items.title'),
        AiConnector(id: 'rs_3', name: 'OpenAlex Bibliographic DB', category: ConnectorCategory.research, url: 'https://api.openalex.org/works?search=machine-learning', jsonPath: 'results.display_name'),
        AiConnector(id: 'rs_4', name: 'Semantic Scholar Open Graph', category: ConnectorCategory.research, url: 'https://api.semanticscholar.org/graph/v1/paper/search?query=neural&limit=3', jsonPath: 'data.title'),
        AiConnector(id: 'rs_5', name: 'PubChem PUG Chemistry', category: ConnectorCategory.research, url: 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/aspirin/property/IUPACName/JSON', jsonPath: 'PropertyTable.Properties.IUPACName'),
        AiConnector(id: 'rs_6', name: 'REST Countries API', category: ConnectorCategory.research, url: 'https://restcountries.com/v3.1/name/japan', jsonPath: 'name.common'),
        AiConnector(id: 'rs_7', name: 'USGS Earthquake Hazard', category: ConnectorCategory.research, url: 'https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&minmagnitude=5.0', jsonPath: 'features.properties.title'),
      ];
}

class AppSettings {
  bool pinLockEnabled;
  String pinCode;
  String themeName;
  int cpuThreads;
  String geminiApiKey;
  String openAiApiKey;
  String anthropicApiKey;
  String openRouterApiKey;
  String ollamaUrl;

  AppSettings({
    this.pinLockEnabled = false,
    this.pinCode = '1234',
    this.themeName = 'Warm Parchment',
    this.cpuThreads = 4,
    this.geminiApiKey = '',
    this.openAiApiKey = '',
    this.anthropicApiKey = '',
    this.openRouterApiKey = '',
    this.ollamaUrl = 'http://localhost:11434',
  });
}

class OriginLegal {
  static const String privacyPolicy = '''
Privacy Policy & Terms of Service (by Origin)

1. Data Ownership & Offline Privacy
"Memories" is built and maintained by Origin with a strict local-first privacy architecture. All diary entries, mood logs, photos, and pre-bundled GGUF models are stored exclusively in secure local device storage (app cache & memory database). We do not collect, upload, or monetize personal user data. Zero cloud telemetry.

2. Strict Acceptable Use & Prohibitions
By using Memories, you agree that this application and its AI connectors / local models:
- Hereby CANNOT be used for illegal purposes, unlawful activities, or harmful conduct.
- Shall not be employed to generate malicious code, harassment, fraudulent content, or violate local and international laws.

3. AI & Connectors Disclaimer
Cloud APIs (OpenAI, Gemini, Anthropic, OpenRouter, Ollama) and pre-configured web search connectors transmit data only when explicitly invoked by the user with valid credentials. Pre-bundled GGUF model runs on-device via Llama.cpp for native builds (APK/EXE/MSI/Linux/macOS), while Web builds rely on Cloud APIs and free Connectors.

Copyright © 2025 Origin. All rights reserved.
''';
}
