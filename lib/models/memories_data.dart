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

enum ConnectorCategory { wellBeing, academics, research, shopping }

class AiConnector {
  final String id;
  final String name;
  final ConnectorCategory category;
  final String url;
  final String jsonPath;
  bool isEnabled;
  final bool isPreconfigured;
  final String region;

  AiConnector({
    required this.id,
    required this.name,
    required this.category,
    required this.url,
    required this.jsonPath,
    this.isEnabled = true,
    this.isPreconfigured = true,
    this.region = 'Global',
  });
}

class PreconfiguredConnectors {
  static List<AiConnector> get defaultList => [
        // --- Shopping & Brands (Shopify Public /products.json Zero-Auth APIs) ---
        // 🇮🇳 India Brands
        AiConnector(id: 'shop_in_1', name: 'BoAt Lifestyle 🇮🇳', category: ConnectorCategory.shopping, url: 'https://boat-lifestyle.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_2', name: 'Noise 🇮🇳', category: ConnectorCategory.shopping, url: 'https://gonoise.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_3', name: 'Snitch 🇮🇳', category: ConnectorCategory.shopping, url: 'https://snitch.co.in/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_4', name: 'Bombay Shaving Co 🇮🇳', category: ConnectorCategory.shopping, url: 'https://bombayshavingcompany.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_5', name: 'The Man Company 🇮🇳', category: ConnectorCategory.shopping, url: 'https://themancompany.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_6', name: 'mCaffeine 🇮🇳', category: ConnectorCategory.shopping, url: 'https://mcaffeine.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_7', name: 'Mamaearth 🇮🇳', category: ConnectorCategory.shopping, url: 'https://mamaearth.in/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_8', name: 'Plum Goodness 🇮🇳', category: ConnectorCategory.shopping, url: 'https://plumgoodness.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_9', name: 'Kama Ayurveda 🇮🇳', category: ConnectorCategory.shopping, url: 'https://kamaayurveda.in/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_10', name: 'Heads Up For Tails 🇮🇳', category: ConnectorCategory.shopping, url: 'https://headsupfortails.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_11', name: 'Sleepy Owl Coffee 🇮🇳', category: ConnectorCategory.shopping, url: 'https://sleepyowl.co/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_12', name: 'Blue Tokai Coffee 🇮🇳', category: ConnectorCategory.shopping, url: 'https://bluetokaicoffee.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_13', name: 'Country Bean 🇮🇳', category: ConnectorCategory.shopping, url: 'https://countrybean.in/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_14', name: 'Chaayos Online 🇮🇳', category: ConnectorCategory.shopping, url: 'https://chaayos.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_15', name: 'Suta Bombay 🇮🇳', category: ConnectorCategory.shopping, url: 'https://suta.in/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_16', name: 'Bummer Underwear 🇮🇳', category: ConnectorCategory.shopping, url: 'https://bummer.in/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_17', name: 'DaMENSCH 🇮🇳', category: ConnectorCategory.shopping, url: 'https://damensch.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_18', name: 'The Souled Store 🇮🇳', category: ConnectorCategory.shopping, url: 'https://thesouledstore.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_19', name: 'Bewakoof Storefront 🇮🇳', category: ConnectorCategory.shopping, url: 'https://bewakoof.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_20', name: 'DailyObjects 🇮🇳', category: ConnectorCategory.shopping, url: 'https://dailyobjects.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_21', name: 'Chumbak 🇮🇳', category: ConnectorCategory.shopping, url: 'https://chumbak.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_22', name: 'Nua Woman 🇮🇳', category: ConnectorCategory.shopping, url: 'https://nuawoman.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_23', name: 'Sanfe 🇮🇳', category: ConnectorCategory.shopping, url: 'https://sanfe.in/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_24', name: 'Pee Safe 🇮🇳', category: ConnectorCategory.shopping, url: 'https://peesafe.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_25', name: 'Vahdam Teas 🇮🇳', category: ConnectorCategory.shopping, url: 'https://vahdam.in/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_26', name: 'Yoga Bar 🇮🇳', category: ConnectorCategory.shopping, url: 'https://yogabar.in/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_27', name: 'Whole Truth Foods 🇮🇳', category: ConnectorCategory.shopping, url: 'https://thewholetruthfoods.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_28', name: 'Pipa Bella 🇮🇳', category: ConnectorCategory.shopping, url: 'https://pipabella.com/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_29', name: 'Giva Jewellery 🇮🇳', category: ConnectorCategory.shopping, url: 'https://giva.co/products.json?limit=10', jsonPath: 'products', region: 'India'),
        AiConnector(id: 'shop_in_30', name: 'Voylla Fashion 🇮🇳', category: ConnectorCategory.shopping, url: 'https://voylla.com/products.json?limit=10', jsonPath: 'products', region: 'India'),

        // 🇺🇸 United States Stores
        AiConnector(id: 'shop_us_1', name: 'Gymshark US 🇺🇸', category: ConnectorCategory.shopping, url: 'https://gymshark.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_2', name: 'Allbirds 🇺🇸', category: ConnectorCategory.shopping, url: 'https://allbirds.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_3', name: 'Kith 🇺🇸', category: ConnectorCategory.shopping, url: 'https://kith.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_4', name: 'Chubbies Shorts 🇺🇸', category: ConnectorCategory.shopping, url: 'https://chubbiesshorts.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_5', name: 'Brooklinen 🇺🇸', category: ConnectorCategory.shopping, url: 'https://brooklinen.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_6', name: 'Tuft & Needle 🇺🇸', category: ConnectorCategory.shopping, url: 'https://tuftandneedle.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_7', name: 'Parachute Home 🇺🇸', category: ConnectorCategory.shopping, url: 'https://parachutehome.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_8', name: 'Ridge Wallet 🇺🇸', category: ConnectorCategory.shopping, url: 'https://ridgewallet.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_9', name: 'Bellroy US 🇺🇸', category: ConnectorCategory.shopping, url: 'https://bellroy.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_10', name: 'Peak Design 🇺🇸', category: ConnectorCategory.shopping, url: 'https://peakdesign.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_11', name: 'Nomad Goods 🇺🇸', category: ConnectorCategory.shopping, url: 'https://nomadgoods.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_12', name: 'Casetify 🇺🇸', category: ConnectorCategory.shopping, url: 'https://casetify.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_13', name: 'ColourPop Cosmetics 🇺🇸', category: ConnectorCategory.shopping, url: 'https://colourpop.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_14', name: 'Kylie Cosmetics 🇺🇸', category: ConnectorCategory.shopping, url: 'https://kyliecosmetics.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_15', name: 'Glossier 🇺🇸', category: ConnectorCategory.shopping, url: 'https://glossier.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_16', name: 'Jones Soda 🇺🇸', category: ConnectorCategory.shopping, url: 'https://jonessoda.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_17', name: 'Death Wish Coffee 🇺🇸', category: ConnectorCategory.shopping, url: 'https://deathwishcoffee.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_18', name: 'Bulletproof Coffee 🇺🇸', category: ConnectorCategory.shopping, url: 'https://bulletproof.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_19', name: 'Liquid Death 🇺🇸', category: ConnectorCategory.shopping, url: 'https://liquiddeath.com/products.json?limit=10', jsonPath: 'products', region: 'US'),
        AiConnector(id: 'shop_us_20', name: 'Spindrift Market 🇺🇸', category: ConnectorCategory.shopping, url: 'https://spindriftmarket.com/products.json?limit=10', jsonPath: 'products', region: 'US'),

        // 🇬🇧 United Kingdom Stores
        AiConnector(id: 'shop_uk_1', name: 'Gymshark UK 🇬🇧', category: ConnectorCategory.shopping, url: 'https://uk.gymshark.com/products.json?limit=10', jsonPath: 'products', region: 'UK'),
        AiConnector(id: 'shop_uk_2', name: 'Lounge Underwear 🇬🇧', category: ConnectorCategory.shopping, url: 'https://lounge.com/products.json?limit=10', jsonPath: 'products', region: 'UK'),
        AiConnector(id: 'shop_uk_3', name: 'Oh Polly 🇬🇧', category: ConnectorCategory.shopping, url: 'https://ohpolly.com/products.json?limit=10', jsonPath: 'products', region: 'UK'),
        AiConnector(id: 'shop_uk_4', name: 'Represent Clo 🇬🇧', category: ConnectorCategory.shopping, url: 'https://representclo.com/products.json?limit=10', jsonPath: 'products', region: 'UK'),
        AiConnector(id: 'shop_uk_5', name: 'Trapstar London 🇬🇧', category: ConnectorCategory.shopping, url: 'https://trapstarlondon.com/products.json?limit=10', jsonPath: 'products', region: 'UK'),
        AiConnector(id: 'shop_uk_6', name: 'TALA Activewear 🇬🇧', category: ConnectorCategory.shopping, url: 'https://wearetala.com/products.json?limit=10', jsonPath: 'products', region: 'UK'),
        AiConnector(id: 'shop_uk_7', name: 'Lucy & Yak 🇬🇧', category: ConnectorCategory.shopping, url: 'https://lucyandyak.com/products.json?limit=10', jsonPath: 'products', region: 'UK'),
        AiConnector(id: 'shop_uk_8', name: 'Grind Coffee London 🇬🇧', category: ConnectorCategory.shopping, url: 'https://grind.co.uk/products.json?limit=10', jsonPath: 'products', region: 'UK'),
        AiConnector(id: 'shop_uk_9', name: 'Chillys Bottles 🇬🇧', category: ConnectorCategory.shopping, url: 'https://chillys.com/products.json?limit=10', jsonPath: 'products', region: 'UK'),
        AiConnector(id: 'shop_uk_10', name: 'Hotel Chocolat 🇬🇧', category: ConnectorCategory.shopping, url: 'https://hotelchocolat.com/products.json?limit=10', jsonPath: 'products', region: 'UK'),

        // 🌍 Global Mock & Test Feeds
        AiConnector(id: 'shop_gl_1', name: 'The Ordinary 🇨🇦', category: ConnectorCategory.shopping, url: 'https://theordinary.com/products.json?limit=10', jsonPath: 'products', region: 'Global'),
        AiConnector(id: 'shop_gl_2', name: 'Nudie Jeans 🇸🇪', category: ConnectorCategory.shopping, url: 'https://nudiejeans.com/products.json?limit=10', jsonPath: 'products', region: 'Global'),
        AiConnector(id: 'shop_gl_3', name: 'FakeStoreAPI (Mock E-comm) 🌍', category: ConnectorCategory.shopping, url: 'https://fakestoreapi.com/products?limit=10', jsonPath: 'title', region: 'Global'),
        AiConnector(id: 'shop_gl_4', name: 'DummyJSON Products 🌍', category: ConnectorCategory.shopping, url: 'https://dummyjson.com/products?limit=10', jsonPath: 'products', region: 'Global'),

        // --- Well-Being ---
        AiConnector(id: 'wb_1', name: 'ZenQuotes API', category: ConnectorCategory.wellBeing, url: 'https://zenquotes.io/api/random', jsonPath: 'q'),
        AiConnector(id: 'wb_2', name: 'Advice Slip API', category: ConnectorCategory.wellBeing, url: 'https://api.adviceslip.com/advice', jsonPath: 'advice'),
        AiConnector(id: 'wb_3', name: 'Affirmations.dev', category: ConnectorCategory.wellBeing, url: 'https://affirmations.dev/', jsonPath: 'affirmation'),
        AiConnector(id: 'wb_4', name: 'Open-Meteo Weather', category: ConnectorCategory.wellBeing, url: 'https://api.open-meteo.com/v1/forecast?latitude=28.61&longitude=77.20&current=temperature_2m', jsonPath: 'current.temperature_2m'),
        AiConnector(id: 'wb_5', name: 'World Time API', category: ConnectorCategory.wellBeing, url: 'https://worldtimeapi.org/api/timezone/Etc/UTC', jsonPath: 'datetime'),
        AiConnector(id: 'wb_6', name: 'Bored API', category: ConnectorCategory.wellBeing, url: 'https://bored-api.appbrewery.com/random', jsonPath: 'activity'),
        AiConnector(id: 'wb_7', name: 'Daily Stoic Quotes', category: ConnectorCategory.wellBeing, url: 'https://api.themotivate365.com/stoic-quote', jsonPath: 'quote'),
        AiConnector(id: 'wb_8', name: 'Numbers API', category: ConnectorCategory.wellBeing, url: 'http://numbersapi.com/random/trivia?json', jsonPath: 'text'),

        // --- Academics ---
        AiConnector(id: 'ac_1', name: 'Free Dictionary API', category: ConnectorCategory.academics, url: 'https://api.dictionaryapi.dev/api/v2/entries/en/', jsonPath: 'meanings'),
        AiConnector(id: 'ac_2', name: 'Datamuse Linguistic API', category: ConnectorCategory.academics, url: 'https://api.datamuse.com/words?ml=test', jsonPath: 'word'),
        AiConnector(id: 'ac_3', name: 'Wikipedia REST Summary', category: ConnectorCategory.academics, url: 'https://en.wikipedia.org/api/rest_v1/page/summary/', jsonPath: 'extract'),
        AiConnector(id: 'ac_4', name: 'Wiktionary Definition', category: ConnectorCategory.academics, url: 'https://en.wiktionary.org/api/rest_v1/page/definition/', jsonPath: 'definition'),
        AiConnector(id: 'ac_5', name: 'Open Library Books Search', category: ConnectorCategory.academics, url: 'https://openlibrary.org/search.json?q=kotlin', jsonPath: 'docs.title'),

        // --- Research ---
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
