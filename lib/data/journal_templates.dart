import '../models/memories_data.dart';

class JournalTemplate {
  final String title;
  final String icon;
  final String category;
  final MoodType defaultMood;
  final String content;

  JournalTemplate({
    required this.title,
    required this.icon,
    required this.category,
    required this.defaultMood,
    required this.content,
  });
}

class JournalTemplates {
  static List<JournalTemplate> get list => [
        JournalTemplate(
          title: 'Daily Reflection & Mood Log',
          icon: '✨',
          category: 'Personal',
          defaultMood: MoodType.joy,
          content: '''
### Morning Focus
- What am I grateful for today?
- Key goal for today:

### Evening Review
- Best moment of the day:
- What did I learn today?
- How did I manage my stress or emotions?
''',
        ),
        JournalTemplate(
          title: 'Academic Research & Study Log',
          icon: '🔬',
          category: 'Research',
          defaultMood: MoodType.serenity,
          content: '''
### Research Topic / Subject: 
- **Keywords / Paper Title**: 
- **Core Hypothesis**: 

### Key Discoveries & Insights:
- Main Discovery:
- Summary of findings:

### Next Steps:
1. Literature review check via arXiv connector
2. Review study notes
''',
        ),
        JournalTemplate(
          title: 'Homework & Problem Solving Log',
          icon: '📚',
          category: 'Homework',
          defaultMood: MoodType.serenity,
          content: '''
### Subject / Course: 
- **Assignment Details**: 
- **Concepts Applied**: 

### Problem Breakdown:
- Step 1: 
- Step 2: 
''',
        ),
        JournalTemplate(
          title: 'Evening Gratitude & Stoic Reflection',
          icon: '🌸',
          category: 'Gratitude Log',
          defaultMood: MoodType.gratitude,
          content: '''
### Stoic Daily Principles
> "You have power over your mind - not outside events. Realize this, and you will find strength." — Marcus Aurelius

### 3 Things I Am Thankful For:
1. 
2. 
3. 

### Emotional Check-in:
- Overall inner calm level (1-10):
''',
        ),
        JournalTemplate(
          title: 'Idea Brainstorm & Goals',
          icon: '💡',
          category: 'Ideas & Goals',
          defaultMood: MoodType.passion,
          content: '''
### Big Idea Title: 
- **Core Concept**: 
- **Why it matters**: 

### Actionable Action Plan:
- [ ] Research existing literature / solutions
- [ ] Draft prototype outline
- [ ] Review with Ai⁺ assistant
''',
        ),
      ];
}
