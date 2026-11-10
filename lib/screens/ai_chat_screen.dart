import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/memories_data.dart';
import '../services/cloud_ai_service.dart';

class ChatMessage {
  final String sender;
  final String text;
  final bool isLoading;
  ChatMessage(this.sender, this.text, {this.isLoading = false});
}

class AiChatScreen extends StatefulWidget {
  final List<MemoryEntry> entries;
  final List<AiConnector> connectors;
  final AppSettings settings;
  final MemoryEntry? activeEntry;
  final VoidCallback onBack;
  final Function(String) onReplaceNoteContent;
  final Function(String) onAppendNoteContent;

  const AiChatScreen({
    super.key,
    required this.entries,
    required this.connectors,
    required this.settings,
    this.activeEntry,
    required this.onBack,
    required this.onReplaceNoteContent,
    required this.onAppendNoteContent,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _promptController = TextEditingController();
  late List<ChatMessage> _messages;
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final hasKey = widget.settings.geminiApiKey.isNotEmpty ||
        widget.settings.openAiApiKey.isNotEmpty ||
        widget.settings.anthropicApiKey.isNotEmpty ||
        widget.settings.openRouterApiKey.isNotEmpty;

    final engineBadge = hasKey
        ? '🔑 Active API Provider Configured'
        : (kIsWeb ? '🌐 Web Mode (Zero API Key)' : '⚡ Native On-Device GGUF Mode');

    final hasNoteContent = widget.activeEntry != null && widget.activeEntry!.content.trim().isNotEmpty;
    final noteTitle = widget.activeEntry?.title.isEmpty ?? true ? "Untitled Entry" : widget.activeEntry!.title;

    final initialGreeting = hasNoteContent
        ? 'Hello! I am your Ai⁺ companion ($engineBadge). I have loaded your note "$noteTitle". How would you like me to analyze, enhance, or rewrite it?'
        : 'Hello! I am your Ai⁺ companion ($engineBadge). Type a message or select an action to start generating real-time AI responses!';

    _messages = [ChatMessage('Ai⁺', initialGreeting)];
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isGenerating) return;

    final userText = text.trim();
    _promptController.clear();

    setState(() {
      _messages.add(ChatMessage('User', userText));
      _messages.add(ChatMessage('Ai⁺', 'Generating response...', isLoading: true));
      _isGenerating = true;
    });
    _scrollToBottom();

    final aiResult = await CloudAiService.generateResponse(
      prompt: userText,
      settings: widget.settings,
      noteTitle: widget.activeEntry?.title ?? '',
      noteContent: widget.activeEntry?.content ?? '',
      connectors: widget.connectors,
    );

    if (mounted) {
      setState(() {
        _messages.removeLast(); // Remove loading bubble
        _messages.add(ChatMessage('Ai⁺', aiResult));
        _isGenerating = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _rewriteNote() async {
    if (_isGenerating) return;

    final noteText = widget.activeEntry?.content ?? '';
    final isNoteEmpty = noteText.trim().isEmpty;
    final prompt = isNoteEmpty
        ? 'Please write a new, beautifully structured personal diary entry with key reflections and learnings.'
        : 'Please rewrite, polish, and enhance the active diary note. Make it eloquent and add structured key takeaways.';

    setState(() {
      _messages.add(ChatMessage('User', isNoteEmpty ? 'Write a new note for me' : 'Polish and edit my note'));
      _messages.add(ChatMessage('Ai⁺', 'Analyzing note and generating polish...', isLoading: true));
      _isGenerating = true;
    });
    _scrollToBottom();

    final aiResult = await CloudAiService.generateResponse(
      prompt: prompt,
      settings: widget.settings,
      noteTitle: widget.activeEntry?.title ?? '',
      noteContent: widget.activeEntry?.content ?? '',
      connectors: widget.connectors,
    );

    if (mounted) {
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage('Ai⁺', aiResult));
        _isGenerating = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNoteEmpty = widget.activeEntry?.content.trim().isEmpty ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A2E2B)),
          onPressed: widget.onBack,
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE07A5F), Color(0xFFF4B942)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Text('Ai⁺', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(width: 4),
                  Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Dedicated AI Panel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A2E2B)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Context Header
          if (widget.activeEntry != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFDFB),
                border: Border(bottom: BorderSide(color: Color(0xFFD4C9BD))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, size: 16, color: Color(0xFF8C4A32)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isNoteEmpty ? 'Active Note: (Empty Canvas)' : 'Active Note: "${widget.activeEntry!.title.isEmpty ? "Untitled Entry" : widget.activeEntry!.title}"',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4A2E2B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Quick Actions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (widget.activeEntry != null)
                  ActionChip(
                    avatar: const Text('✍️'),
                    label: Text(isNoteEmpty ? 'Write Note for Me' : 'Polish & Edit Note'),
                    backgroundColor: const Color(0xFFE07A5F).withValues(alpha: 0.15),
                    side: const BorderSide(color: Color(0xFFE07A5F)),
                    onPressed: _rewriteNote,
                  ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Text('📊'),
                  label: const Text('Summarize Moods'),
                  onPressed: () => _sendMessage('Please analyze my journal entries and provide a summary of my top emotional moods and growth trends.'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Text('🔍'),
                  label: const Text('Query Connectors'),
                  onPressed: () => _sendMessage('Query my active academic and research connectors to find inspiring quotes and study insights.'),
                ),
              ],
            ),
          ),

          // Chat Messages Feed
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isAi = msg.sender == 'Ai⁺';
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                    decoration: BoxDecoration(
                      color: isAi ? const Color(0xFFFFFDFB) : const Color(0xFF8C4A32),
                      borderRadius: BorderRadius.circular(16),
                      border: isAi ? Border.all(color: const Color(0xFFD4C9BD)) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.sender,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isAi ? const Color(0xFF8C4A32) : const Color(0xFFF3EFEA),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (msg.isLoading)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8C4A32)),
                              ),
                              SizedBox(width: 8),
                              Text('Generating live response...', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF8C4A32))),
                            ],
                          )
                        else
                          Text(
                            msg.text,
                            style: TextStyle(
                              fontSize: 15,
                              color: isAi ? const Color(0xFF4A2E2B) : Colors.white,
                              fontFamily: isAi ? 'Serif' : null,
                              height: 1.4,
                            ),
                          ),
                        if (isAi && !msg.isLoading && index > 0 && widget.activeEntry != null) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF8C4A32)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: () {
                                  widget.onReplaceNoteContent(msg.text);
                                },
                                icon: const Icon(Icons.edit_note, size: 18, color: Color(0xFF8C4A32)),
                                label: const Text('Replace Note', style: TextStyle(fontSize: 12, color: Color(0xFF8C4A32), fontWeight: FontWeight.bold)),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFD4C9BD)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: () {
                                  widget.onAppendNoteContent('\n\n${msg.text}');
                                },
                                icon: const Icon(Icons.add, size: 18, color: Color(0xFF4A2E2B)),
                                label: const Text('Append', style: TextStyle(fontSize: 12, color: Color(0xFF4A2E2B))),
                              ),
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFDFB),
              border: Border(top: BorderSide(color: Color(0xFFD4C9BD))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        hintText: 'Message Ai⁺...',
                        filled: true,
                        fillColor: const Color(0xFFF4EFEA),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF8C4A32),
                    ),
                    child: IconButton(
                      icon: _isGenerating
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.arrow_upward, color: Colors.white),
                      onPressed: () => _sendMessage(_promptController.text),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
