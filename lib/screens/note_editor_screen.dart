import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pasteboard/pasteboard.dart';

import '../data/journal_templates.dart';
import '../models/memories_data.dart';
import '../services/thought_service.dart';
import '../widgets/diary_paper_canvas.dart';
import '../widgets/emotion_picker_dialog.dart';
import '../widgets/export_sheet.dart';
import '../widgets/photo_viewer_dialog.dart';

class NoteEditorScreen extends StatefulWidget {
  final MemoryEntry? initialEntry;
  final Function(MemoryEntry) onSaveEntry;
  final VoidCallback onBack;
  final Function(String title, String content) onOpenAiAssistantWithContent;

  const NoteEditorScreen({
    super.key,
    this.initialEntry,
    required this.onSaveEntry,
    required this.onBack,
    required this.onOpenAiAssistantWithContent,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late MoodType _selectedMood;
  late String _selectedCategory;
  late PaperStyle _paperStyle;
  late bool _isBookmarked;
  late List<String> _photos;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialEntry?.title ?? '');
    _contentController = TextEditingController(text: widget.initialEntry?.content ?? '');
    _selectedMood = widget.initialEntry?.mood ?? MoodType.joy;
    _selectedCategory = widget.initialEntry?.category ?? 'Personal';
    _paperStyle = widget.initialEntry?.paperStyle ?? PaperStyle.ruled;
    _isBookmarked = widget.initialEntry?.isBookmarked ?? false;
    _photos = List.from(widget.initialEntry?.photos ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _triggerAiAssistant() {
    widget.onOpenAiAssistantWithContent(
      _titleController.text,
      _contentController.text,
    );
  }

  Future<void> _handlePasteFromClipboard() async {
    try {
      final bytes = await Pasteboard.image;
      if (bytes != null && bytes.isNotEmpty) {
        final b64 = base64Encode(bytes);
        setState(() {
          _photos.add('data:image/png;base64,$b64');
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✓ Image pasted from clipboard!')));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No image found in clipboard.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to paste: $e')));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _photos.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image picker error: $e')));
    }
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF7F2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Photo / Attachment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A2E2B))),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.paste, color: Color(0xFF8C4A32)),
                title: const Text('Paste from Clipboard'),
                onTap: () {
                  Navigator.pop(context);
                  _handlePasteFromClipboard();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF8C4A32)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF8C4A32)),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _save() {
    final entry = (widget.initialEntry ??
            MemoryEntry(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              content: _contentController.text,
              timestamp: DateTime.now(),
            ))
      ..title = _titleController.text
      ..content = _contentController.text
      ..mood = _selectedMood
      ..category = _selectedCategory
      ..paperStyle = _paperStyle
      ..isBookmarked = _isBookmarked
      ..photos = _photos;

    widget.onSaveEntry(entry);
    widget.onBack();
  }

  MemoryEntry _getCurrentDraft() {
    return (widget.initialEntry ??
        MemoryEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          content: _contentController.text,
          timestamp: DateTime.now(),
        ))
      ..title = _titleController.text
      ..content = _contentController.text
      ..mood = _selectedMood
      ..category = _selectedCategory
      ..paperStyle = _paperStyle
      ..isBookmarked = _isBookmarked
      ..photos = _photos;
  }

  void _showExportSheet() {
    final entry = _getCurrentDraft();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportSheet(entry: entry),
    );
  }

  void _showEmotionPicker() {
    showDialog(
      context: context,
      builder: (_) => EmotionPickerDialog(
        selectedMood: _selectedMood,
        onMoodSelected: (mood) {
          setState(() {
            _selectedMood = mood;
          });
        },
      ),
    );
  }

  void _showThoughtOfTheDayDialog() {
    final today = DateTime.now();
    final thought = ThoughtService.getThoughtForDate(today);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFFAF7F2),
          title: Row(
            children: const [
              Text('💡', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                'Thought of the Day',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4A2E2B)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4C9BD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${thought.thought}"',
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 15,
                        height: 1.5,
                        color: Color(0xFF4A2E2B),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '— ${thought.author}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF8C4A32)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4EFEA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            thought.topic,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF968A7E), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Color(0xFF8C4A32), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showTemplatesSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Journal / Paper Template', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A2E2B))),
              const SizedBox(height: 12),
              ...JournalTemplates.list.map((tmpl) {
                return ListTile(
                  leading: Text(tmpl.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(tmpl.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(tmpl.category),
                  onTap: () {
                    setState(() {
                      _titleController.text = tmpl.title;
                      _contentController.text = tmpl.content;
                      _selectedCategory = tmpl.category;
                      _selectedMood = tmpl.defaultMood;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageThumbnail(String source) {
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
    final dateStr = widget.initialEntry != null
        ? '${widget.initialEntry!.timestamp.year}-${widget.initialEntry!.timestamp.month.toString().padLeft(2, '0')}-${widget.initialEntry!.timestamp.day.toString().padLeft(2, '0')}'
        : '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

    final categoriesList = DefaultCategories.list.map((e) => e['name']!).toList();
    if (!categoriesList.contains(_selectedCategory)) {
      categoriesList.add(_selectedCategory);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFE8DF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFE8DF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A2E2B)),
          onPressed: widget.onBack,
        ),
        title: Text(
          widget.initialEntry == null ? 'New Journal Entry' : 'Edit Entry',
          style: const TextStyle(color: Color(0xFF4A2E2B), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Color(0xFFE07A5F)),
            tooltip: 'Dedicated Ai⁺ Chat Panel',
            onPressed: _triggerAiAssistant,
          ),
          InkWell(
            onTap: _showEmotionPicker,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _selectedMood.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _selectedMood.color, width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('✳️', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Text(_selectedMood.emoji, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(_isBookmarked ? Icons.star : Icons.star_border, color: _isBookmarked ? const Color(0xFFF4B942) : Colors.grey),
            onPressed: () => setState(() => _isBookmarked = !_isBookmarked),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_motion, color: Color(0xFF8C4A32)),
            tooltip: 'Templates',
            onPressed: _showTemplatesSheet,
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Color(0xFF4A2E2B)),
            tooltip: 'Export Note / Save As',
            onPressed: _showExportSheet,
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF8C4A32)),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 650),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDFB),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ],
              border: Border.all(color: const Color(0xFFD8C8B8), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD4C9BD),
                      width: 1.2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Diary',
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6E6259),
                              letterSpacing: 1,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4EFEA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'DATE ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF968A7E),
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6E6259),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Text('Folder: ', style: TextStyle(fontSize: 12, color: Color(0xFF968A7E), fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: _selectedCategory,
                            underline: const SizedBox(),
                            isDense: true,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCategory = val);
                            },
                            items: categoriesList.map((catName) {
                              final catMap = DefaultCategories.list.firstWhere((e) => e['name'] == catName, orElse: () => {'name': catName, 'icon': '📁'});
                              return DropdownMenuItem(
                                value: catName,
                                child: Text('${catMap['icon']} $catName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                          ),
                          const SizedBox(width: 8),

                          InkWell(
                            onTap: _showThoughtOfTheDayDialog,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4EFEA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD4C9BD)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('💡 ', style: TextStyle(fontSize: 12)),
                                  Text(
                                    'Thought of the Day',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8C4A32)),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),
                          DropdownButton<PaperStyle>(
                            value: _paperStyle,
                            underline: const SizedBox(),
                            isDense: true,
                            onChanged: (val) {
                              if (val != null) setState(() => _paperStyle = val);
                            },
                            items: PaperStyle.values.map((st) {
                              return DropdownMenuItem(
                                value: st,
                                child: Text('📄 ${st.label}', style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _titleController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A2E2B),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Entry Title...',
                          hintStyle: TextStyle(color: Color(0xFFC5B4A4)),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                      const Divider(color: Color(0xFFCDBBAA), thickness: 1.5),

                      Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: LinedPaperPainter(
                                lineHeight: 28.0,
                                lineColor: _paperStyle.lineColor,
                                style: _paperStyle,
                              ),
                            ),
                          ),
                          TextField(
                            controller: _contentController,
                            onChanged: (_) => setState(() {}),
                            maxLines: 12,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.86,
                              color: Color(0xFF4A2E2B),
                              fontFamily: 'Serif',
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Write your daily thoughts, reflections, or homework here...',
                              hintStyle: TextStyle(color: Color(0xFFC5B4A4)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F3EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2D6C8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'NOTES / DOODLES / ATTACHMENTS:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF968A7E),
                                    letterSpacing: 1,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_a_photo, size: 20, color: Color(0xFF8C4A32)),
                                  tooltip: 'Attach Image / Photo',
                                  onPressed: _showAttachmentMenu,
                                )
                              ],
                            ),
                            if (_photos.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _photos.map((p) {
                                    return Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => PhotoViewerDialog(photoData: p),
                                            );
                                          },
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            margin: const EdgeInsets.only(right: 8, top: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFFDFB),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: const Color(0xFFD4C9BD)),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(11),
                                              child: _buildImageThumbnail(p),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _photos.remove(p);
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    'Origin',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 13,
                      color: Color(0xFFB5A89B),
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.5,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
