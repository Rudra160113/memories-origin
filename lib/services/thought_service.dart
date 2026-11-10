import 'dart:convert';

class DailyThought {
  final int id;
  final String thought;
  final String author;
  final String topic;

  DailyThought({
    required this.id,
    required this.thought,
    required this.author,
    required this.topic,
  });

  factory DailyThought.fromJson(Map<String, dynamic> json) {
    return DailyThought(
      id: json['id'] ?? 0,
      thought: json['thought'] ?? '',
      author: json['author'] ?? 'Origin',
      topic: json['topic'] ?? 'Daily Inspiration',
    );
  }
}

class ThoughtService {
  static const String jsonSource = '''
[
  {
    "id": 1,
    "thought": "The secret of getting ahead is getting started. Small daily reflections build lifelong wisdom.",
    "author": "Mark Twain",
    "topic": "Motivation & Focus"
  },
  {
    "id": 2,
    "thought": "You have power over your mind - not outside events. Realize this, and you will find inner calm.",
    "author": "Marcus Aurelius",
    "topic": "Stoic Resilience"
  },
  {
    "id": 3,
    "thought": "It does not matter how slowly you go as long as you do not stop.",
    "author": "Confucius",
    "topic": "Persistence & Growth"
  },
  {
    "id": 4,
    "thought": "In the middle of difficulty lies opportunity. Keep writing your story.",
    "author": "Albert Einstein",
    "topic": "Academic Discovery"
  },
  {
    "id": 5,
    "thought": "Gratitude turns what we have into enough. Reflect on the beauty of today.",
    "author": "Aesop",
    "topic": "Mindfulness & Gratitude"
  },
  {
    "id": 6,
    "thought": "Simplicity is the ultimate sophistication. Keep your thoughts clear and genuine.",
    "author": "Leonardo da Vinci",
    "topic": "Clarity of Thought"
  },
  {
    "id": 7,
    "thought": "What we achieve inwardly will change outer reality.",
    "author": "Plutarch",
    "topic": "Self Reflection"
  }
]
''';

  static List<DailyThought> get thoughtsList {
    final List decoded = jsonDecode(jsonSource);
    return decoded.map((e) => DailyThought.fromJson(e)).toList();
  }

  static DailyThought getThoughtForDate(DateTime date) {
    // Deterministic seed based on year, month, and day
    final daySeed = date.year * 10000 + date.month * 100 + date.day;
    final list = thoughtsList;
    final index = daySeed % list.length;
    return list[index];
  }
}
