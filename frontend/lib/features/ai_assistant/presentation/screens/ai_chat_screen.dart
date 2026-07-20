import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/ai_assistant/data/mock_ai_data.dart';

/// Phase 2K — AI Chat Screen.
///
/// Shows a conversation. For a new chat, opens a blank session
/// with an optional pre-filled prompt from [extra].
/// For a history chat, loads the mock conversation.
class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key, this.sessionId, this.extra});
  final String? sessionId;
  final Map<String, dynamic>? extra;

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _scrollCtrl = ScrollController();
  final _inputCtrl = TextEditingController();
  bool _isTyping = false;

  late List<MockChatMessage> _messages;
  late String _title;

  @override
  void initState() {
    super.initState();
    if (widget.sessionId != null) {
      final session = MockAIData.chatHistory
          .firstWhere((s) => s.id == widget.sessionId,
              orElse: () => MockAIData.chatHistory.first);
      _title = session.title;
      _messages =
          List<MockChatMessage>.from(MockAIData.getConversation(widget.sessionId!));
    } else {
      _title = 'New Chat';
      _messages = [];
      // Pre-fill prompt if provided
      final prompt = widget.extra?['prompt'] as String? ?? '';
      if (prompt.isNotEmpty) {
        _inputCtrl.text = prompt;
      }
      // Add welcome message
      _messages.add(MockChatMessage(
        id: 'welcome',
        role: MessageRole.assistant,
        content: 'Hi! I\'m **StudyFlow AI**. How can I help you study today? '
            'You can ask me to explain topics, summarise notes, generate quizzes, '
            'or create a study plan. 🎓',
        timestamp: DateTime.now(),
      ));
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(MockChatMessage(
        id: 'u${_messages.length}',
        role: MessageRole.user,
        content: text,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
      if (_title == 'New Chat') {
        _title = text.length > 40 ? '${text.substring(0, 40)}...' : text;
      }
    });
    _inputCtrl.clear();
    _scrollToBottom();

    // Simulate AI response delay
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(MockChatMessage(
        id: 'a${_messages.length}',
        role: MessageRole.assistant,
        content: _mockResponse(text),
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  String _mockResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('avl') || lower.contains('tree')) {
      return 'An **AVL tree** is a self-balancing BST. '
          'It maintains a balance factor of -1, 0, or +1 for every node. '
          'When balance is violated, it performs rotations (LL, RR, LR, RL) to restore balance. '
          'All operations run in **O(log n)** time.';
    }
    if (lower.contains('sql') || lower.contains('join')) {
      return 'SQL **JOINs** combine rows from two tables:\n\n'
          '• **INNER JOIN** — only matching rows\n'
          '• **LEFT JOIN** — all left + matching right\n'
          '• **RIGHT JOIN** — all right + matching left\n'
          '• **FULL OUTER JOIN** — all rows from both\n\n'
          'Use `ON table1.id = table2.fk_id` to specify the join condition.';
    }
    if (lower.contains('quiz') || lower.contains('question')) {
      return '**Quiz: Data Structures** 📝\n\n'
          'Q1: What is the time complexity of BST insertion?\n'
          'A) O(1)  B) O(log n)  C) O(n)  D) O(n²)\n\n'
          'Q2: Which traversal visits Left → Root → Right?\n'
          'A) Pre-order  B) In-order  C) Post-order  D) Level-order\n\n'
          'Q3: What data structure follows LIFO?\n'
          'A) Queue  B) Stack  C) Heap  D) Graph\n\n'
          '*(This is a UI placeholder — real AI responses coming in Phase 3)*';
    }
    if (lower.contains('summarize') || lower.contains('summary')) {
      return '**Summary** 📋\n\n'
          'Based on your notes, here are the key points:\n\n'
          '1. Core concept defined with proper terminology\n'
          '2. Main algorithm/process explained step-by-step\n'
          '3. Time and space complexity analysis\n'
          '4. Real-world applications and use cases\n'
          '5. Common pitfalls to avoid\n\n'
          '*(This is a UI placeholder — real summarization coming in Phase 3)*';
    }
    if (lower.contains('flashcard') || lower.contains('flash')) {
      return '**Flashcards Generated** 🎴\n\n'
          '**Card 1**\nFront: What is a balanced BST?\n'
          'Back: A BST where the height difference between left and right subtrees is at most 1.\n\n'
          '**Card 2**\nFront: What is the balance factor formula?\n'
          'Back: BF = Height(Left) - Height(Right)\n\n'
          '*(This is a UI placeholder — real flashcard generation coming in Phase 3)*';
    }
    return 'I understand you\'re asking about **"$input"**. '
        'This is a UI placeholder response — in Phase 3, I will be connected '
        'to a real AI model and provide accurate, contextual answers based on your study materials. '
        'For now, feel free to explore the interface! 🤖';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title,
                style: AppTypography.titleSmall.copyWith(
                    color: AppColors.onSurface),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(
              children: [
                Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('StudyFlow AI',
                    style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _messages.length && _isTyping) {
                  return _TypingIndicator();
                }
                return _MessageBubble(message: _messages[i]);
              },
            ),
          ),

          // Quick suggestions (shown when empty new chat)
          if (_messages.length <= 1 && widget.sessionId == null)
            _QuickSuggestions(
              onSelect: (s) {
                _inputCtrl.text = s;
                _send();
              },
            ),

          // Input bar
          _InputBar(
            controller: _inputCtrl,
            isTyping: _isTyping,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final MockChatMessage message;

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
        left: _isUser ? AppSpacing.xxl : 0,
        right: _isUser ? 0 : AppSpacing.xxl,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!_isUser) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.tertiary, size: 16),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: _isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(_isUser ? 16 : 4),
                  bottomRight: Radius.circular(_isUser ? 4 : 16),
                ),
                border: _isUser
                    ? null
                    : Border.all(color: AppColors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6, offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: _isUser
                  ? Text(message.content,
                      style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.onPrimary, height: 1.5))
                  : _MarkdownText(text: message.content),
            ),
          ),
          if (_isUser) const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }
}

// Simple bold markdown renderer
class _MarkdownText extends StatelessWidget {
  const _MarkdownText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.isEmpty) return const SizedBox(height: AppSpacing.xs);
        if (line.startsWith('**') && line.endsWith('**') &&
            line.length > 4) {
          return Text(line.substring(2, line.length - 2),
              style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.5));
        }
        if (line.startsWith('• ') || line.startsWith('- ')) {
          return Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                      width: 5, height: 5,
                      decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle)),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(line.substring(2),
                      style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.onSurface, height: 1.5)),
                ),
              ],
            ),
          );
        }
        // Inline bold: **text**
        final parts = line.split('**');
        if (parts.length > 1) {
          final spans = <TextSpan>[];
          for (int i = 0; i < parts.length; i++) {
            spans.add(TextSpan(
              text: parts[i],
              style: i.isOdd
                  ? AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700, height: 1.5)
                  : AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurface, height: 1.5),
            ));
          }
          return RichText(text: TextSpan(children: spans));
        }
        return Text(line,
            style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurface, height: 1.5));
      }).toList(),
    );
  }
}

// ── Typing Indicator ──────────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers =
      List.generate(3, (i) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 400),
          ));

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: AppSpacing.xs, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppColors.tertiary, size: 16),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedXl,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Row(
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedBuilder(
                  animation: _controllers[i],
                  builder: (ctx, _) => Transform.translate(
                    offset: Offset(0, -4 * _controllers[i].value),
                    child: Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(
                            alpha: 0.4 + _controllers[i].value * 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Suggestions ─────────────────────────────────────────────────────────
class _QuickSuggestions extends StatelessWidget {
  const _QuickSuggestions({required this.onSelect});
  final ValueChanged<String> onSelect;

  static const _suggestions = [
    'Explain AVL trees',
    'Generate a DS quiz',
    'Summarise OS notes',
    'Create SQL flashcards',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.xs),
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () => onSelect(_suggestions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.10),
              borderRadius: AppRadius.roundedFull,
              border: Border.all(
                  color: AppColors.tertiary.withValues(alpha: 0.30)),
            ),
            child: Text(_suggestions[i],
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurface)),
          ),
        ),
      ),
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isTyping,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool isTyping;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
            top: BorderSide(color: AppColors.outlineVariant)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Message StudyFlow AI...',
                hintStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.onSurfaceVariant),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs),
                isDense: true,
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: isTyping ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: isTyping
                    ? AppColors.outline
                    : AppColors.primary,
                borderRadius: AppRadius.roundedFull,
              ),
              child: Icon(
                isTyping
                    ? Icons.hourglass_top_rounded
                    : Icons.send_rounded,
                color: AppColors.onPrimary, size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
