import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_animations.dart';
import '../core/config/theme_config.dart';
import '../models/chat_message_model.dart';
import '../providers/ai_provider.dart';

class AILegalChatScreen extends ConsumerStatefulWidget {
  final String userName;

  const AILegalChatScreen({super.key, required this.userName});

  @override
  ConsumerState<AILegalChatScreen> createState() => _AILegalChatScreenState();
}

class _AILegalChatScreenState extends ConsumerState<AILegalChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(chatProvider).conversationHistory.isEmpty) {
        ref.read(chatProvider.notifier).addMessage(
              'assistant',
              'Hi ${widget.userName}! I\'m JusLegal, your AI legal assistant. '
                  'How can I help you with your consumer issue today?',
            );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? value]) async {
    final message = (value ?? _textController.text).trim();
    if (message.isEmpty || ref.read(chatProvider).isSending) return;
    _textController.clear();
    _scrollToBottom();

    try {
      await ref.read(chatProvider.notifier).sendUserMessage(message);
    } catch (_) {
      if (!mounted) return;
      final error = ref.read(chatProvider).error ??
          'Failed to get an AI response. Please try again.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous?.conversationHistory.length !=
              next.conversationHistory.length ||
          previous?.isSending != next.isSending) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: AppColors.shadowStrong,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('JusLegal AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
            Text('Legal guidance, not legal advice',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New chat',
            onPressed: chat.isSending
                ? null
                : () => ref.read(chatProvider.notifier).clearHistory(),
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: Column(
            children: [
              Expanded(child: _messageList(chat.conversationHistory)),
              if (chat.isSending) const _TypingIndicator(),
              _inputArea(chat),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageList(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      itemCount: messages.length,
      itemBuilder: (context, index) => AppAnimations.fadeSlideIn(
        _MessageBubble(message: messages[index]),
        duration: const Duration(milliseconds: 280),
        beginOffset: const Offset(0, 0.04),
      ),
    );
  }

  Widget _inputArea(ChatState chat) {
    final showSuggestions = chat.conversationHistory.length <= 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSuggestions)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SuggestionChip('Damaged online order', _sendMessage),
                  _SuggestionChip('Banking fraud', _sendMessage),
                  _SuggestionChip('Refund not received', _sendMessage),
                ],
              ),
            ),
          if (showSuggestions) const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  enabled: !chat.isSending,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 16),
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Describe your legal issue...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: const Color(0xFFF8FBFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.legalGold,
                shape: const CircleBorder(),
                elevation: 8,
                shadowColor: AppColors.shadowGold,
                child: IconButton(
                  tooltip: 'Send message',
                  onPressed: chat.isSending ? null : _sendMessage,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    foregroundColor: AppColors.textPrimary,
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          // Prevent overly long lines when the app is used on a tablet.
          maxWidth: math.min(MediaQuery.sizeOf(context).width * .80, 560),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser
              ? AppColors.userBubbleGradient
              : AppColors.botBubbleGradient,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isUser ? 24 : 8),
            bottomRight: Radius.circular(isUser ? 8 : 24),
          ),
          border: Border.all(
            color: isUser
                ? AppColors.white.withValues(alpha: 0.35)
                : AppColors.white.withValues(alpha: 0.9),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? AppColors.shadow.withValues(alpha: 0.62)
                  : AppColors.shadowBlack.withValues(alpha: 0.13),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isUser
            ? Text(
                message.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              )
            : MarkdownBody(
                data: message.content,
                selectable: true,
                onTapLink: (text, href, title) => _openLink(context, href),
                styleSheet: _markdownStyle(context),
              ),
      ),
    );
  }

  static Future<void> _openLink(BuildContext context, String? href) async {
    if (href == null) return;
    final uri = Uri.tryParse(href);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open this link.')),
        );
      }
    }
  }

  static MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
          height: 1.5,
        );
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: base,
      h3: base?.copyWith(
        color: AppColors.legalGold,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h3Padding: const EdgeInsets.only(top: 12, bottom: 4),
      strong: base?.copyWith(
          color: AppColors.legalGold, fontWeight: FontWeight.w700),
      a: base?.copyWith(
        color: AppColors.legalGold,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.legalGold,
        fontWeight: FontWeight.w600,
      ),
      listBullet: base?.copyWith(color: AppColors.legalGold, fontSize: 16),
      listIndent: 24,
      listBulletPadding: const EdgeInsets.only(right: 8),
      code: const TextStyle(
        color: AppColors.textPrimary,
        backgroundColor: AppColors.grey100,
        fontFamily: 'monospace',
        fontSize: 14,
      ),
      codeblockDecoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(4),
      ),
      codeblockPadding: const EdgeInsets.all(4),
      blockSpacing: 8,
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 18, bottom: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.botBubbleGradient,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowBlack.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RotatingSpinner(),
                SizedBox(width: 8),
                _AnimatedDots(),
                SizedBox(width: 8),
                Text(
                  'JusLegal is responding...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _RotatingSpinner extends StatefulWidget {
  const _RotatingSpinner();

  @override
  State<_RotatingSpinner> createState() => _RotatingSpinnerState();
}

class _RotatingSpinnerState extends State<_RotatingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(
        Icons.sync_rounded,
        color: AppColors.legalGold,
        size: 18,
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => SizedBox(
          width: 30,
          height: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              final phase = (_controller.value * 3 - index).abs();
              final opacity = (1 - phase).clamp(.25, 1.0);
              return Opacity(
                opacity: opacity,
                child: const CircleAvatar(
                    radius: 3, backgroundColor: AppColors.legalGold),
              );
            }),
          ),
        ),
      );
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final Future<void> Function([String?]) onTap;

  const _SuggestionChip(this.label, this.onTap);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: AppAnimations.pressScale(
          onTap: () => onTap(label),
          borderRadius: BorderRadius.circular(999),
          splashColor: AppColors.legalGold.withValues(alpha: 0.18),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowBlack,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
}
