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

enum ConnectorCategory { wellBeing, academics, research, shopping, encyclopedia }

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
        // --- 📖 Encyclopedias & Wiki Knowledge Engines ---
        // 🇮🇳 India & Regional Indic Knowledge (18 Endpoints)
        AiConnector(id: 'enc_in_1', name: 'Hindi Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://hi.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_2', name: 'Bengali Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://bn.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_3', name: 'Marathi Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://mr.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_4', name: 'Tamil Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://ta.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_5', name: 'Telugu Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://te.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_6', name: 'Gujarati Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://gu.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_7', name: 'Malayalam Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://ml.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_8', name: 'Kannada Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://kn.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_9', name: 'Punjabi Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://pa.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_10', name: 'Odia Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://or.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_11', name: 'Assamese Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://as.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_12', name: 'Sanskrit Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://sa.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_13', name: 'Urdu Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://ur.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_14', name: 'Bhojpuri Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://bh.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_15', name: 'Maithili Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://mai.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_16', name: 'Santali Wikipedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://sat.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_17', name: 'India Water Portal Wiki 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://indiawaterportal.org/w/api.php', jsonPath: 'query.search', region: 'India'),
        AiConnector(id: 'enc_in_18', name: 'Bharatpedia Encyclopedia 🇮🇳', category: ConnectorCategory.encyclopedia, url: 'https://bharatpedia.org/w/api.php', jsonPath: 'query.search', region: 'India'),

        // 🌍 General Knowledge, Science & Archives (25 Endpoints)
        AiConnector(id: 'enc_gl_1', name: 'English Wikipedia 🌐', category: ConnectorCategory.encyclopedia, url: 'https://en.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_2', name: 'Simple English Wikipedia 🌐', category: ConnectorCategory.encyclopedia, url: 'https://simple.wikipedia.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_3', name: 'Wikidata Knowledge Graph 🌐', category: ConnectorCategory.encyclopedia, url: 'https://www.wikidata.org/w/api.php', jsonPath: 'search', region: 'Global'),
        AiConnector(id: 'enc_gl_4', name: 'Wikiquote 🌐', category: ConnectorCategory.encyclopedia, url: 'https://en.wikiquote.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_5', name: 'Wiktionary Etymology 🌐', category: ConnectorCategory.encyclopedia, url: 'https://en.wiktionary.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_6', name: 'Wikisource Literature 🌐', category: ConnectorCategory.encyclopedia, url: 'https://en.wikisource.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_7', name: 'Wikivoyage Geography 🌐', category: ConnectorCategory.encyclopedia, url: 'https://en.wikivoyage.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_8', name: 'Wikispecies Biology 🌐', category: ConnectorCategory.encyclopedia, url: 'https://species.wikimedia.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_9', name: 'Wikimedia Commons 🌐', category: ConnectorCategory.encyclopedia, url: 'https://commons.wikimedia.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_10', name: 'Citizendium Peer-Reviewed 🌐', category: ConnectorCategory.encyclopedia, url: 'https://citizendium.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_11', name: 'Scholarpedia Science 🌐', category: ConnectorCategory.encyclopedia, url: 'http://scholarpedia.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_12', name: 'Encyclopedia of Mathematics 📐', category: ConnectorCategory.encyclopedia, url: 'https://encyclopediaofmath.org/api/rest_v1/page/summary/Calculus', jsonPath: 'extract', region: 'Global'),
        AiConnector(id: 'enc_gl_13', name: 'Stanford Encyclopedia of Philosophy (SEP) 🧠', category: ConnectorCategory.encyclopedia, url: 'https://plato.stanford.edu/search/searcher.py?query=ethics', jsonPath: 'extract', region: 'Global'),
        AiConnector(id: 'enc_gl_14', name: 'Internet Encyclopedia of Philosophy (IEP) 🧠', category: ConnectorCategory.encyclopedia, url: 'https://iep.utm.edu/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_15', name: 'Appropedia Sustainability 🌿', category: ConnectorCategory.encyclopedia, url: 'https://www.appropedia.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_16', name: 'Encyclopedia of Life (EOL) 🦋', category: ConnectorCategory.encyclopedia, url: 'https://eol.org/api/search/1.0.json?q=panthera', jsonPath: 'results', region: 'Global'),
        AiConnector(id: 'enc_gl_17', name: 'Open Library Books Encyclopedia 📚', category: ConnectorCategory.encyclopedia, url: 'https://openlibrary.org/search.json?q=physics', jsonPath: 'docs.title', region: 'Global'),
        AiConnector(id: 'enc_gl_18', name: 'Library of Congress 🏛️', category: ConnectorCategory.encyclopedia, url: 'https://www.loc.gov/search/?fo=json&q=history', jsonPath: 'results.title', region: 'Global'),
        AiConnector(id: 'enc_gl_19', name: 'Europeana Open Knowledge 🇪🇺', category: ConnectorCategory.encyclopedia, url: 'https://api.europeana.eu/record/v2/opensearch.json?query=art', jsonPath: 'items', region: 'Global'),
        AiConnector(id: 'enc_gl_20', name: 'PhilPapers Philosophy 🧠', category: ConnectorCategory.encyclopedia, url: 'https://philpapers.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_21', name: 'Everipedia / IQ.wiki 🌐', category: ConnectorCategory.encyclopedia, url: 'https://iq.wiki/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_22', name: 'Ballotpedia Politics 🏛️', category: ConnectorCategory.encyclopedia, url: 'https://ballotpedia.org/w/api.php', jsonPath: 'query.search', region: 'Global'),
        AiConnector(id: 'enc_gl_23', name: 'GovTrack US Legislation 🏛️', category: ConnectorCategory.encyclopedia, url: 'https://www.govtrack.us/api/v2/bill?limit=5', jsonPath: 'objects.title', region: 'Global'),
        AiConnector(id: 'enc_gl_24', name: 'Wikiversity Open Learning 🎓', category: ConnectorCategory.encyclopedia, url: 'https://en.wikiversity.org/w/api.php', jsonPath: 'query.search', region: 'Global'),

        // 🎮 Gaming, Software & Pop-Culture Fandom Wikis (35 Endpoints)
        AiConnector(id: 'enc_gm_1', name: 'Minecraft Wiki ⛏️', category: ConnectorCategory.encyclopedia, url: 'https://minecraft.wiki/w/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_2', name: 'Wookieepedia (Star Wars) 🚀', category: ConnectorCategory.encyclopedia, url: 'https://starwars.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_3', name: 'Memory Alpha (Star Trek) 🖖', category: ConnectorCategory.encyclopedia, url: 'https://memory-alpha.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_4', name: 'Bulbapedia (Pokémon) ⚡', category: ConnectorCategory.encyclopedia, url: 'https://bulbapedia.bulbagarden.net/w/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_5', name: 'Tardis Core (Doctor Who) ⏳', category: ConnectorCategory.encyclopedia, url: 'https://tardis.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_6', name: 'Marvel Database 🦸', category: ConnectorCategory.encyclopedia, url: 'https://marvel.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_7', name: 'DC Database 🦇', category: ConnectorCategory.encyclopedia, url: 'https://dc.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_8', name: 'Harry Potter Wiki 🪄', category: ConnectorCategory.encyclopedia, url: 'https://harrypotter.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_9', name: 'Tolkien Gateway (LOTR) 💍', category: ConnectorCategory.encyclopedia, url: 'https://tolkiengateway.net/w/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_10', name: 'AWOIAF (Game of Thrones) ⚔️', category: ConnectorCategory.encyclopedia, url: 'https://awoiaf.westeros.org/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_11', name: 'Elder Scrolls Wiki (UESP) 🗡️', category: ConnectorCategory.encyclopedia, url: 'https://en.uesp.net/w/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_12', name: 'Fallout Wiki (Nukapedia) ☢️', category: ConnectorCategory.encyclopedia, url: 'https://fallout.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_13', name: 'Witcher Wiki 🐺', category: ConnectorCategory.encyclopedia, url: 'https://witcher.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_14', name: 'Genshin Impact Wiki 🌠', category: ConnectorCategory.encyclopedia, url: 'https://genshin-impact.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_15', name: 'GTA Wiki 🚗', category: ConnectorCategory.encyclopedia, url: 'https://gta.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_16', name: 'Final Fantasy Wiki 🗡️', category: ConnectorCategory.encyclopedia, url: 'https://finalfantasy.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_17', name: 'Dark Souls Wiki ⚔️', category: ConnectorCategory.encyclopedia, url: 'https://darksouls.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_18', name: 'Elden Ring Wiki 💍', category: ConnectorCategory.encyclopedia, url: 'https://eldenring.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_19', name: 'Zelda Wiki 🛡️', category: ConnectorCategory.encyclopedia, url: 'https://zeldawiki.wiki/w/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_20', name: 'Runescape Wiki ⚔️', category: ConnectorCategory.encyclopedia, url: 'https://runescape.wiki/w/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_21', name: 'Old School Runescape Wiki 🗡️', category: ConnectorCategory.encyclopedia, url: 'https://oldschool.runescape.wiki/w/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_22', name: 'Warhammer 40k Lexicanum 🛡️', category: ConnectorCategory.encyclopedia, url: 'https://wh40k.lexicanum.com/w/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_23', name: 'D&D 5e Wiki 🎲', category: ConnectorCategory.encyclopedia, url: 'https://dnd5e.wikidot.com/w/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_24', name: 'Pathfinder Wiki 🎲', category: ConnectorCategory.encyclopedia, url: 'https://pathfinderwiki.com/w/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_25', name: 'Arch Linux Technical Wiki 💻', category: ConnectorCategory.encyclopedia, url: 'https://wiki.archlinux.org/w/api.php', jsonPath: 'query.search', region: 'Technical'),
        AiConnector(id: 'enc_gm_26', name: 'Gentoo Linux Wiki 💻', category: ConnectorCategory.encyclopedia, url: 'https://wiki.gentoo.org/w/api.php', jsonPath: 'query.search', region: 'Technical'),
        AiConnector(id: 'enc_gm_27', name: 'Debian Linux Wiki 💻', category: ConnectorCategory.encyclopedia, url: 'https://wiki.debian.org/w/api.php', jsonPath: 'query.search', region: 'Technical'),
        AiConnector(id: 'enc_gm_28', name: 'Ubuntu Community Wiki 💻', category: ConnectorCategory.encyclopedia, url: 'https://help.ubuntu.com/w/api.php', jsonPath: 'query.search', region: 'Technical'),
        AiConnector(id: 'enc_gm_29', name: 'NixOS Linux Wiki 💻', category: ConnectorCategory.encyclopedia, url: 'https://wiki.nixos.org/w/api.php', jsonPath: 'query.search', region: 'Technical'),
        AiConnector(id: 'enc_gm_30', name: 'Doom Wiki 💥', category: ConnectorCategory.encyclopedia, url: 'https://doomwiki.org/w/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_31', name: 'Terraria Wiki 🌳', category: ConnectorCategory.encyclopedia, url: 'https://terraria.wiki.gg/w/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_32', name: 'Warframe Wiki 🤖', category: ConnectorCategory.encyclopedia, url: 'https://warframe.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_33', name: 'Cyberpunk 2077 Wiki 🌆', category: ConnectorCategory.encyclopedia, url: 'https://cyberpunk.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_34', name: 'League of Legends Wiki ⚔️', category: ConnectorCategory.encyclopedia, url: 'https://leagueoflegends.fandom.com/api.php', jsonPath: 'query.search', region: 'Gaming'),
        AiConnector(id: 'enc_gm_35', name: 'Destiny Pedia 🚀', category: ConnectorCategory.encyclopedia, url: 'https://destinypedia.com/w/api.php', jsonPath: 'query.search', region: 'Gaming'),

        // ⛩️ Anime, Manga & Pop Fiction Encyclopedias (15 Endpoints)
        AiConnector(id: 'enc_an_1', name: 'Jujutsu Kaisen Wiki ⛩️', category: ConnectorCategory.encyclopedia, url: 'https://jujutsu-kaisen.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_2', name: 'One Piece Wiki 🏴‍☠️', category: ConnectorCategory.encyclopedia, url: 'https://onepiece.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_3', name: 'Naruto Wiki 🍃', category: ConnectorCategory.encyclopedia, url: 'https://naruto.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_4', name: 'Bleach Wiki ⚔️', category: ConnectorCategory.encyclopedia, url: 'https://bleach.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_5', name: 'Dragon Ball Wiki 🐉', category: ConnectorCategory.encyclopedia, url: 'https://dragonball.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_6', name: 'Attack on Titan Wiki 🗡️', category: ConnectorCategory.encyclopedia, url: 'https://attackontitan.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_7', name: 'My Hero Academia Wiki 💥', category: ConnectorCategory.encyclopedia, url: 'https://myheroacademia.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_8', name: 'Demon Slayer Wiki ⚔️', category: ConnectorCategory.encyclopedia, url: 'https://kimetsu-no-yaiba.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_9', name: 'Eminence in Shadow Wiki 🌙', category: ConnectorCategory.encyclopedia, url: 'https://the-eminence-in-shadow.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_10', name: 'Chainsaw Man Wiki 🪚', category: ConnectorCategory.encyclopedia, url: 'https://chainsaw-man.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_11', name: 'JoJo Bizarre Encyclopedia 🌟', category: ConnectorCategory.encyclopedia, url: 'https://jojowiki.com/w/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_12', name: 'Type-Moon (Fate/stay) Wiki 🗡️', category: ConnectorCategory.encyclopedia, url: 'https://typemoon.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_13', name: 'Sword Art Online Wiki ⚔️', category: ConnectorCategory.encyclopedia, url: 'https://swordartonline.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_14', name: 'Overlord Wiki 💀', category: ConnectorCategory.encyclopedia, url: 'https://overlordmaruyama.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),
        AiConnector(id: 'enc_an_15', name: 'Slime Tensei Wiki 🔮', category: ConnectorCategory.encyclopedia, url: 'https://tensura.fandom.com/api.php', jsonPath: 'query.search', region: 'Anime'),

        // 🌐 Keyless Direct REST APIs for General Encyclopedic Lookups (7 Endpoints)
        AiConnector(id: 'enc_rst_1', name: 'REST Countries Encyclopedia 🌍', category: ConnectorCategory.encyclopedia, url: 'https://restcountries.com/v3.1/all', jsonPath: 'name.common', region: 'Global'),
        AiConnector(id: 'enc_rst_2', name: 'NASA Exoplanet Archive 🪐', category: ConnectorCategory.encyclopedia, url: 'https://exoplanetarchive.ipac.caltech.edu/TAP/sync?query=select+top+10+pl_name,hostname+from+ps&format=json', jsonPath: 'pl_name', region: 'Science'),
        AiConnector(id: 'enc_rst_3', name: 'NOAA FishWatch Species 🐟', category: ConnectorCategory.encyclopedia, url: 'https://www.fishwatch.gov/api/species', jsonPath: 'Species Name', region: 'Science'),
        AiConnector(id: 'enc_rst_4', name: 'PokeAPI Pokémon Encyclopedia ⚡', category: ConnectorCategory.encyclopedia, url: 'https://pokeapi.co/api/v2/pokemon?limit=10', jsonPath: 'results.name', region: 'Gaming'),
        AiConnector(id: 'enc_rst_5', name: 'Frankfurter Currency History 💱', category: ConnectorCategory.encyclopedia, url: 'https://api.frankfurter.app/latest', jsonPath: 'rates', region: 'Global'),
        AiConnector(id: 'enc_rst_6', name: 'Open Meteo Climate Database 🌤️', category: ConnectorCategory.encyclopedia, url: 'https://archive-api.open-meteo.com/v1/era5?latitude=28.61&longitude=77.20&start_date=2024-01-01&end_date=2024-01-02&daily=temperature_2m_max', jsonPath: 'daily', region: 'Science'),
        AiConnector(id: 'enc_rst_7', name: 'CoinGecko Crypto Encyclopedia 🪙', category: ConnectorCategory.encyclopedia, url: 'https://api.coingecko.com/api/v3/coins/list?include_platform=false', jsonPath: 'name', region: 'Finance'),

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
