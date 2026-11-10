import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/memories_data.dart';
import '../widgets/photo_viewer_dialog.dart';

enum SortOption {
  newest('Newest First', Icons.arrow_downward),
  oldest('Oldest First', Icons.arrow_upward),
  aToZ('A ➔ Z (Title)', Icons.sort_by_alpha),
  zToA('Z ➔ A (Title)', Icons.sort_by_alpha);

  final String label;
  final IconData icon;
  const SortOption(this.label, this.icon);
}

class TimelineScreen extends StatefulWidget {
  final List<MemoryEntry> entries;
  final VoidCallback onNewEntry;
  final Function(MemoryEntry) onOpenEntry;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenAiAssistant;
  final VoidCallback onOpenAnalytics;
  final VoidCallback onOpenPrivacyAudit;
  final Function(MoodType?) onSelectMoodFilter;
  final MoodType? selectedMoodFilter;
  final Function(MemoryEntry) onToggleBookmark;
  final Function(MemoryEntry) onDeleteEntry;
  final Function(MemoryEntry, String) onExportEntry;
  final Function(MemoryEntry, String) onUpdateEntryCategory;

  const TimelineScreen({
    super.key,
    required this.entries,
    required this.onNewEntry,
    required this.onOpenEntry,
    required this.onOpenSettings,
    required this.onOpenAiAssistant,
    required this.onOpenAnalytics,
    required this.onOpenPrivacyAudit,
    required this.onSelectMoodFilter,
    required this.selectedMoodFilter,
    required this.onToggleBookmark,
    required this.onDeleteEntry,
    required this.onExportEntry,
    required this.onUpdateEntryCategory,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  bool _onlyBookmarked = false;
  SortOption _selectedSort = SortOption.newest;
  final List<String> _userCustomCategories = [];

  List<String> get _allCategories {
    final list = DefaultCategories.list.map((e) => e['name']!).toList();
    for (var cat in _userCustomCategories) {
      if (!list.contains(cat)) list.add(cat);
    }
    for (var entry in widget.entries) {
      if (!list.contains(entry.category)) list.add(entry.category);
    }
    return list;
  }

  void _showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFFAF7F2),
          title: Row(
            children: const [
              Text('📁', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text('Select Folder Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A2E2B))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Text('📂', style: TextStyle(fontSize: 20)),
                  title: const Text('All Categories / Folders', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: _selectedCategory == null ? const Icon(Icons.check, color: Color(0xFF8C4A32)) : null,
                  onTap: () {
                    setState(() => _selectedCategory = null);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ..._allCategories.map((catName) {
                  final isSel = _selectedCategory == catName;
                  final defaultMap = DefaultCategories.list.firstWhere((e) => e['name'] == catName, orElse: () => {'name': catName, 'icon': '📁'});
                  return ListTile(
                    leading: Text(defaultMap['icon']!, style: const TextStyle(fontSize: 20)),
                    title: Text(catName, style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? const Color(0xFF8C4A32) : const Color(0xFF4A2E2B))),
                    trailing: isSel ? const Icon(Icons.check, color: Color(0xFF8C4A32)) : null,
                    onTap: () {
                      setState(() => _selectedCategory = catName);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Color(0xFF8C4A32))),
            )
          ],
        );
      },
    );
  }

  void _showAddToCategoryDialog(MemoryEntry entry) {
    final newCatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFFAF7F2),
          title: Text('Add "${entry.title}" to Category', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A2E2B))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose Category Folder:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                ..._allCategories.map((catName) {
                  final isCurrent = entry.category == catName;
                  final defaultMap = DefaultCategories.list.firstWhere((e) => e['name'] == catName, orElse: () => {'name': catName, 'icon': '📁'});
                  return ListTile(
                    leading: Text(defaultMap['icon']!, style: const TextStyle(fontSize: 18)),
                    title: Text(catName, style: TextStyle(fontSize: 14, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                    trailing: isCurrent ? const Icon(Icons.check, color: Color(0xFF8C4A32)) : null,
                    onTap: () {
                      widget.onUpdateEntryCategory(entry, catName);
                      Navigator.pop(context);
                    },
                  );
                }),
                const Divider(),
                const Text('＋ Create New Category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF8C4A32))),
                const SizedBox(height: 8),
                TextField(
                  controller: newCatController,
                  decoration: InputDecoration(
                    hintText: 'New category name...',
                    filled: true,
                    fillColor: const Color(0xFFFFFDFB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4C9BD))),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8C4A32), foregroundColor: Colors.white),
                    onPressed: () {
                      final newCat = newCatController.text.trim();
                      if (newCat.isNotEmpty) {
                        setState(() {
                          if (!_userCustomCategories.contains(newCat)) {
                            _userCustomCategories.add(newCat);
                          }
                        });
                        widget.onUpdateEntryCategory(entry, newCat);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save to New Category'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MemoryEntry> filtered = widget.entries.where((entry) {
      final matchesSearch = entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesMood = widget.selectedMoodFilter == null || entry.mood == widget.selectedMoodFilter;
      final matchesCategory = _selectedCategory == null || entry.category == _selectedCategory;
      final matchesBookmark = !_onlyBookmarked || entry.isBookmarked;

      return matchesSearch && matchesMood && matchesCategory && matchesBookmark;
    }).toList();

    filtered.sort((a, b) {
      switch (_selectedSort) {
        case SortOption.newest:
          return b.timestamp.compareTo(a.timestamp);
        case SortOption.oldest:
          return a.timestamp.compareTo(b.timestamp);
        case SortOption.aToZ:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SortOption.zToA:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFEFE8DF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFE8DF),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Memories',
              style: TextStyle(
                fontFamily: 'Serif',
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2E2B),
                fontSize: 24,
              ),
            ),
            Text(
              'by Origin',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF8C4A32),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Color(0xFFE07A5F)),
            tooltip: 'Ai⁺ Chat Panel',
            onPressed: widget.onOpenAiAssistant,
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Color(0xFF4A2E2B)),
            tooltip: 'Mood Analytics',
            onPressed: widget.onOpenAnalytics,
          ),
          IconButton(
            icon: const Icon(Icons.verified_user_outlined, color: Color(0xFF4A2E2B)),
            tooltip: 'Origin Privacy Audit',
            onPressed: widget.onOpenPrivacyAudit,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF4A2E2B)),
            tooltip: 'Settings & AI Hub',
            onPressed: widget.onOpenSettings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onNewEntry,
        backgroundColor: const Color(0xFF8C4A32),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search thoughts, journal entries, research...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF8C4A32)),
                      filled: true,
                      fillColor: const Color(0xFFFFFDFB),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD4C9BD)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _onlyBookmarked ? Icons.star : Icons.star_border,
                    color: _onlyBookmarked ? const Color(0xFFF4B942) : Colors.grey,
                  ),
                  tooltip: 'Show Bookmarked Only',
                  onPressed: () => setState(() => _onlyBookmarked = !_onlyBookmarked),
                )
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCategory == null ? const Color(0xFFFFFDFB) : const Color(0xFF8C4A32),
                    foregroundColor: _selectedCategory == null ? const Color(0xFF4A2E2B) : Colors.white,
                    side: const BorderSide(color: Color(0xFFD4C9BD)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _showCategoryFilterDialog,
                  icon: const Icon(Icons.folder_outlined, size: 18),
                  label: Text(_selectedCategory == null ? '📁 Categories (All)' : '📁 $_selectedCategory'),
                ),
                const SizedBox(width: 10),

                PopupMenuButton<SortOption>(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4C9BD)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_selectedSort.icon, size: 16, color: const Color(0xFF8C4A32)),
                        const SizedBox(width: 4),
                        Text(_selectedSort.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A2E2B))),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFF8C4A32)),
                      ],
                    ),
                  ),
                  onSelected: (val) => setState(() => _selectedSort = val),
                  itemBuilder: (context) => SortOption.values.map((opt) {
                    return PopupMenuItem<SortOption>(
                      value: opt,
                      child: Row(
                        children: [
                          Icon(opt.icon, size: 18, color: const Color(0xFF8C4A32)),
                          const SizedBox(width: 8),
                          Text(opt.label),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Moods'),
                    selected: widget.selectedMoodFilter == null,
                    onSelected: (_) => widget.onSelectMoodFilter(null),
                    selectedColor: const Color(0xFF8C4A32),
                    labelStyle: TextStyle(
                      color: widget.selectedMoodFilter == null ? Colors.white : const Color(0xFF4A2E2B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ...MoodType.values.map((mood) {
                    final selected = widget.selectedMoodFilter == mood;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text('${mood.emoji} ${mood.label}'),
                        selected: selected,
                        onSelected: (_) => widget.onSelectMoodFilter(mood),
                        selectedColor: mood.color,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF4A2E2B),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('📖', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text('No diary entries found', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final entry = filtered[index];
                        return _PaperCard(
                          entry: entry,
                          onTap: () => widget.onOpenEntry(entry),
                          onToggleBookmark: () => widget.onToggleBookmark(entry),
                          onDelete: () => widget.onDeleteEntry(entry),
                          onExport: (fmt) => widget.onExportEntry(entry, fmt),
                          onAddToCategory: () => _showAddToCategoryDialog(entry),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  final MemoryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;
  final VoidCallback onDelete;
  final Function(String) onExport;
  final VoidCallback onAddToCategory;

  const _PaperCard({
    required this.entry,
    required this.onTap,
    required this.onToggleBookmark,
    required this.onDelete,
    required this.onExport,
    required this.onAddToCategory,
  });

  Widget _buildThumbnail(String source) {
    if (source.startsWith('data:image')) {
      final base64String = source.split(',').last;
      return Image.memory(base64Decode(base64String), fit: BoxFit.cover);
    } else if (source.startsWith('http')) {
      return Image.network(source, fit: BoxFit.cover);
    } else {
      if (kIsWeb) {
        return Image.network(source, fit: BoxFit.cover);
      } else {
        return Image.file(File(source), fit: BoxFit.cover);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-${entry.timestamp.day.toString().padLeft(2, '0')}';

    final categoryMap = DefaultCategories.list.firstWhere(
      (e) => e['name'] == entry.category,
      orElse: () => {'name': entry.category, 'icon': '📁'},
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4C9BD), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          entry.title.isEmpty ? 'Untitled Diary' : entry.title,
                          style: const TextStyle(
                            fontFamily: 'Serif',
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: Color(0xFF4A2E2B),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            entry.isBookmarked ? Icons.star : Icons.star_border,
                            color: entry.isBookmarked ? const Color(0xFFF4B942) : Colors.grey,
                            size: 18,
                          ),
                          onPressed: onToggleBookmark,
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: entry.mood.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: entry.mood.color),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('✳️ ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('${entry.mood.emoji} ${entry.mood.label}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A2E2B))),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF4A2E2B), size: 20),
                        onSelected: (val) {
                          if (val == 'atc') onAddToCategory();
                          if (val == 'download') onExport('PDF');
                          if (val == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'atc',
                            child: Text('📁 Add to Category (ATC)'),
                          ),
                          const PopupMenuItem(
                            value: 'download',
                            child: Text('💾 Download on Device'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('🗑️ Delete Note', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF4EFEA), borderRadius: BorderRadius.circular(6)),
                    child: Text('DATE $dateStr', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF968A7E))),
                  ),
                  const SizedBox(width: 8),
                  Text('• ${categoryMap['icon']} ${entry.category}', style: const TextStyle(fontSize: 11, color: Color(0xFF8C4A32), fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('• ${entry.wordCount} words', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Color(0xFF5C5552), fontFamily: 'Serif', height: 1.4),
              ),
              if (entry.photos.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => PhotoViewerDialog(photoData: entry.photos.first),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFD4C9BD)),
                          color: const Color(0xFFF4EFEA),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: _buildThumbnail(entry.photos.first),
                        ),
                      ),
                    ),
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
