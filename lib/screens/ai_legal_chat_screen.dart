import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:juslegal/core/core.dart';
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

  // Fix 8: covers the provider's debounce interval before isSending is true.
  bool _isSendQueued = false;

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
    final chat = ref.read(chatProvider);
    if (message.isEmpty || chat.isSending || _isSendQueued) return;
    setState(() => _isSendQueued = true);
    _textController.clear();
    _scrollToBottom();
    try {
      await ref.read(chatProvider.notifier).sendUserMessageDebounced(message);
    } finally {
      if (mounted) setState(() => _isSendQueued = false);
    }
  }

  Future<void> _retryLastMessage() async {
    for (final message in ref.read(chatProvider).conversationHistory.reversed) {
      if (message.role == 'user') return _sendMessage(message.content);
    }
  }

  void _scrollToBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final isSendUnavailable = chat.isSending || _isSendQueued;
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous?.conversationHistory.length != next.conversationHistory.length ||
          previous?.isSending != next.isSending) {
        _scrollToBottom();
      }
      // Fix 5: errors are kept in the persistent banner below the composer.
      // ChatNotifier clears state.error after a successful response.
    });

    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmOffWhite,
        foregroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JusLegal AI',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              'Legal guidance, not legal advice',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.slateBlue,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        actions: [
          // Fix 7: expose a useful button name to screen readers.
          Semantics(
            button: true,
            label: 'Start a new chat',
            child: IconButton(
              tooltip: 'New chat',
              onPressed: isSendUnavailable
                  ? null
                  : () => ref.read(chatProvider.notifier).clearHistory(),
              icon: const Icon(Icons.add_comment_outlined, color: AppColors.deepNavy),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Container(
          color: AppColors.warmOffWhite,
          child: Column(children: [
            Expanded(child: _messageList(chat.conversationHistory, isSendUnavailable)),
            if (chat.isSending) const _TypingIndicator(),
            // Fix 2: viewInsets lifts the composer; its scroll view prevents
            // a multi-line composer/banner from being obscured by the keyboard.
            AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: _inputArea(chat, isSendUnavailable),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _messageList(List<ChatMessage> messages, bool isSendUnavailable) => ListView.builder(
    controller: _scrollController,
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    itemCount: messages.length,
    itemBuilder: (context, index) {
      final message = messages[index];
      final isLatestAssistant = !isSendUnavailable &&
          message.role == 'assistant' &&
          index == messages.length - 1;
      return AppAnimations.fadeSlideIn(
        _MessageBubble(
          message: message,
          onOptionSelected: isLatestAssistant ? (opt) => _sendMessage(opt) : null,
        ),
        duration: const Duration(milliseconds: 280),
        beginOffset: const Offset(0, .04),
      );
    },
  );

  Widget _inputArea(ChatState chat, bool isSendUnavailable) {
    final showSuggestions = chat.conversationHistory.length <= 1;
    return SingleChildScrollView(
      // Fix 2: anchor the input at the visible bottom during keyboard resize.
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.warmOffWhite,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (showSuggestions)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _SuggestionChip('Damaged online order', _sendMessage, enabled: !isSendUnavailable),
                _SuggestionChip('Banking fraud', _sendMessage, enabled: !isSendUnavailable),
                _SuggestionChip('Refund not received', _sendMessage, enabled: !isSendUnavailable),
              ]),
            ),
          if (showSuggestions) const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Semantics(
                textField: true,
                label: 'Legal issue message',
                child: TextField(
                  controller: _textController,
                  enabled: !isSendUnavailable,
                  style: const TextStyle(
                    color: AppColors.deepNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Describe your legal issue...',
                    hintStyle: const TextStyle(
                      color: AppColors.slateBlue,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: _inputBorder(AppColors.outline),
                    enabledBorder: _inputBorder(AppColors.outline),
                    focusedBorder: _inputBorder(AppColors.deepNavy, width: 1.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.mustardGold,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22162B49),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Semantics(
                // Fix 7: this stays meaningful when only the icon is read.
                button: true,
                label: isSendUnavailable ? 'Send message unavailable' : 'Send message',
                child: IconButton(
                  tooltip: 'Send message',
                  onPressed: isSendUnavailable ? null : _sendMessage,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    foregroundColor: AppColors.deepNavy,
                  ),
                  icon: const Icon(Icons.arrow_upward_rounded, color: AppColors.deepNavy, size: 22),
                ),
              ),
            ),
          ]),
          if (_isSendQueued) const _QueuedSendIndicator(),
          if (chat.error != null) _ChatErrorBanner(error: chat.error!, onRetry: _retryLastMessage),
        ]),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color, width: width),
  );
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String>? onOptionSelected;

  const _MessageBubble({
    required this.message,
    this.onOptionSelected,
  });

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxBubbleWidth = math.min(screenWidth * 0.78, 560.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(top: 2, right: 8),
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mustardGold,
              ),
              child: const Icon(
                Icons.balance_rounded,
                color: AppColors.deepNavy,
                size: 16,
              ),
            ),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.deepNavy : AppColors.paleBlue,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser ? AppColors.deepNavyDark : const Color(0xFFD4E2EC),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A162B49),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isUser)
                    Text(
                      message.content,
                      softWrap: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else ...[
                    if (message.content.isNotEmpty)
                      MarkdownBody(
                        data: _escapeHtml(message.content),
                        selectable: true,
                        softLineBreak: true,
                        onTapLink: (text, href, title) => _openLink(context, href),
                        styleSheet: _markdownStyle(context),
                      ),
                    if (message.action != null && message.action!.items.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFD4E2EC),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06162B49),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: AppColors.mustardGold,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    message.action!.title,
                                    style: const TextStyle(
                                      color: AppColors.deepNavy,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...message.action!.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(
                                            color: AppColors.mustardGold,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                            color: AppColors.deepNavy,
                                            fontSize: 13.5,
                                            height: 1.35),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (message.question != null &&
                        message.question!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.paleYellow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFF3DE9C),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.help_outline_rounded,
                                color: AppColors.deepNavy, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message.question!,
                                style: const TextStyle(
                                  color: AppColors.deepNavy,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (message.legalContext != null &&
                        message.legalContext!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFD4E2EC),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.gavel_rounded,
                                color: AppColors.slateBlue, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                message.legalContext!,
                                style: const TextStyle(
                                  color: AppColors.slateBlue,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (message.nextStep != null &&
                        message.nextStep!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.mustardGold, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Next: ${message.nextStep}',
                              style: const TextStyle(
                                color: AppColors.slateBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (message.options != null &&
                        message.options!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: message.options!.map((option) {
                          return _QuickOptionChip(
                            label: option.label,
                            onTap: onOptionSelected != null
                                ? () => onOptionSelected!(option.label)
                                : null,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white70
                          : AppColors.slateBlue.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            Container(
              margin: const EdgeInsets.only(top: 2, left: 8),
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.deepNavy,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.mustardGold,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _escapeHtml(String value) => value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

  static Future<void> _openLink(BuildContext context, String? href) async {
    final uri = href == null ? null : Uri.tryParse(href.trim());
    final isSafeWebUri = uri != null && uri.hasAuthority &&
        (uri.scheme.toLowerCase() == 'https' || uri.scheme.toLowerCase() == 'http');
    if (!isSafeWebUri || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open this link.')));
    }
  }

  static MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.deepNavy,
          fontSize: 14.5,
          height: 1.5,
        );
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: base,
      h3: base?.copyWith(
        color: AppColors.deepNavy,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.3,
      ),
      h3Padding: const EdgeInsets.only(top: 10, bottom: 4),
      strong: base?.copyWith(
        color: AppColors.deepNavy,
        fontWeight: FontWeight.w800,
      ),
      a: base?.copyWith(
        color: AppColors.slateBlue,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.slateBlue,
        fontWeight: FontWeight.w700,
      ),
      listBullet: base?.copyWith(color: AppColors.mustardGold, fontSize: 15),
      listIndent: 20,
      listBulletPadding: const EdgeInsets.only(right: 6),
      code: const TextStyle(
        color: AppColors.deepNavy,
        backgroundColor: AppColors.warmOffWhite,
        fontFamily: 'monospace',
        fontSize: 13,
      ),
      codeblockDecoration: BoxDecoration(
        color: AppColors.warmOffWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      codeblockPadding: const EdgeInsets.all(8),
      blockSpacing: 8,
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _spinnerController;
  late final AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 18, bottom: 10),
    child: Semantics(
      liveRegion: true,
      label: 'JusLegal is responding',
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFD4E2EC)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _spinnerController,
                child: const Icon(
                  Icons.sync_rounded,
                  color: AppColors.deepNavy,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              _AnimatedDots(animation: _dotsController),
              const SizedBox(width: 8),
              const Text(
                'JusLegal is responding...',
                style: TextStyle(
                  color: AppColors.deepNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AnimatedDots extends StatelessWidget {
  final Animation<double> animation;
  const _AnimatedDots({required this.animation});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) => SizedBox(
      width: 28, height: 16,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(3, (index) {
        final phase = (animation.value * 3 - index).abs();
        return Opacity(opacity: (1 - phase).clamp(.25, 1.0), child: const CircleAvatar(radius: 3, backgroundColor: AppColors.mustardGold));
      })),
    ),
  );
}

class _QueuedSendIndicator extends StatelessWidget {
  const _QueuedSendIndicator();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Semantics(
      liveRegion: true, label: 'Message queued for sending',
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.deepNavy)),
        SizedBox(width: 8), Text('Message queued…', style: TextStyle(color: AppColors.slateBlue, fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}

class _ChatErrorBanner extends StatelessWidget {
  final String error;
  final Future<void> Function() onRetry;
  const _ChatErrorBanner({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
    decoration: BoxDecoration(color: const Color(0xFFFDE8E8), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFF8B4B4))),
    child: Semantics(
      liveRegion: true, label: 'Send failed: $error',
      child: Row(children: [
        const Icon(Icons.error_outline, color: Color(0xFF9B1C1C)), const SizedBox(width: 8),
        Expanded(child: Text(error, style: const TextStyle(color: Color(0xFF9B1C1C), fontSize: 13, fontWeight: FontWeight.w500))),
        Semantics(button: true, label: 'Retry sending message', child: TextButton(onPressed: onRetry, child: const Text('Retry', style: TextStyle(color: Color(0xFF9B1C1C), fontWeight: FontWeight.w700)))),
      ]),
    ),
  );
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final Future<void> Function([String?]) onTap;
  final bool enabled;
  const _SuggestionChip(this.label, this.onTap, {required this.enabled});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Semantics(
      button: true, enabled: enabled, label: 'Send suggested issue: $label',
      child: AppAnimations.pressScale(
        onTap: enabled ? () => onTap(label) : null,
        borderRadius: BorderRadius.circular(999),
        splashColor: AppColors.mustardGold.withValues(alpha: .18),
        child: Opacity(
          opacity: enabled ? 1 : .55,
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFD4E2EC)),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.deepNavy,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _QuickOptionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _QuickOptionChip({
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.mustardGold.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : AppColors.warmOffWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: enabled ? AppColors.deepNavy : AppColors.outline,
              width: 1.2,
            ),
            boxShadow: enabled
                ? const [
                    BoxShadow(
                      color: Color(0x0A162B49),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? AppColors.deepNavy : AppColors.slateBlue,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
