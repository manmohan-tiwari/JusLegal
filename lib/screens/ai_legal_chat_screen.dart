import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/ai_provider.dart';

// ─────────────────────────────────────────────
// AI LEGAL CHAT SCREEN
// ─────────────────────────────────────────────
// Dependencies to add in pubspec.yaml:
//   speech_to_text: ^6.6.0
//   flutter_tts: ^3.8.5   (optional, for TTS)
//
// Replace the _sendToAI() method with your actual
// Gemini / Groq / OpenRouter service call.
// ─────────────────────────────────────────────

class AILegalChatScreen extends ConsumerStatefulWidget {
  final String userName;

  const AILegalChatScreen({Key? key, required this.userName}) : super(key: key);

  @override
  ConsumerState<AILegalChatScreen> createState() => _AILegalChatScreenState();
}

class _AILegalChatScreenState extends ConsumerState<AILegalChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  bool _isListening = false;
  bool _isTyping = false;
  bool _showGreeting = true;

  late AnimationController _typingController;
  late AnimationController _greetingController;
  late Animation<double> _greetingAnimation;

  // ── Replace with your real speech_to_text instance ──
  // final SpeechToText _speechToText = SpeechToText();
  String _voiceText = '';

  @override
  void initState() {
    super.initState();

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _greetingAnimation = CurvedAnimation(
      parent: _greetingController,
      curve: Curves.easeOutBack,
    );

    // Post-frame: show greeting from AI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _addAIMessage(
          'Hi there, ${widget.userName}! 👋\n\nI\'m JusBot, your personal legal assistant. '
          'How can I help you today?\n\nYou can tell me about any legal problem — '
          'consumer complaints, banking fraud, tenant issues, workplace disputes, and more.',
        );
        setState(() => _showGreeting = false);
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    _greetingController.dispose();
    super.dispose();
  }

  // ── Adds an AI message bubble ──
  void _addAIMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  // ── Sends user message and gets AI response ──
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    // ── AI service call ──
    final aiService = ref.read(aiServiceProvider);
    final result = await aiService.analyzeProblemFromText(text);
    setState(() => _isTyping = false);

    // Build a user-friendly response from the AI analysis
    final caseSummary = result['caseSummary'] ?? result['case_summary'] ?? '';
    final legalAnalysis = result['legalAnalysis'] ?? '';
    final nextSteps = result['nextSteps'] as List<dynamic>? ?? [];
    final applicableLaw = result['applicable_law'] ?? '';

    final response = StringBuffer();
    if (caseSummary.isNotEmpty) {
      response.write('📋 **Case Summary**\n$caseSummary\n\n');
    }
    if (legalAnalysis.isNotEmpty) {
      response.write('⚖️ **Legal Analysis**\n$legalAnalysis\n\n');
    }
    if (nextSteps.isNotEmpty) {
      response.write('📝 **Recommended Steps**\n');
      for (int i = 0; i < nextSteps.length; i++) {
        response.write('${i + 1}. ${nextSteps[i]}\n');
      }
      response.write('\n');
    }
    if (applicableLaw.isNotEmpty) {
      response.write('📜 **Applicable Law**\n$applicableLaw\n\n');
    }
    response.write('⚠️ *This is informational guidance only, not legal advice.*');

    _addAIMessage(response.toString());
  }

  // ── Mock reply — replace with your AI service ──
  String _generateMockReply(String userMessage) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('fraud') || lower.contains('bank')) {
      return 'I understand you\'re dealing with a banking or fraud issue. '
          'This falls under the **Banking Ombudsman Scheme** and the **Consumer Protection Act, 2019**.\n\n'
          'To help you better, could you tell me:\n'
          '1. Which bank is involved?\n'
          '2. What type of transaction or fraud occurred?\n'
          '3. Have you already filed a complaint with the bank?';
    } else if (lower.contains('employer') || lower.contains('salary') || lower.contains('work')) {
      return 'Workplace disputes are covered under the **Industrial Disputes Act** and **Payment of Wages Act**.\n\n'
          'I can help you draft a formal complaint. Please share more details about what happened.';
    } else if (lower.contains('consumer') || lower.contains('product') || lower.contains('refund')) {
      return 'Under the **Consumer Protection Act, 2019**, you have the right to file a complaint '
          'with the District Consumer Disputes Redressal Commission.\n\n'
          'Tell me more about the product/service and the issue you faced.';
    }
    return 'Thank you for sharing that. I\'m analyzing your situation...\n\n'
        'Could you provide a bit more detail so I can give you the most accurate legal guidance? '
        'For example, when did this happen and have you taken any steps already?';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Voice input toggle ──
  Future<void> _toggleVoice() async {
    if (_isListening) {
      setState(() => _isListening = false);
      // _speechToText.stop();
      if (_voiceText.isNotEmpty) {
        _sendMessage(_voiceText);
        _voiceText = '';
      }
    } else {
      setState(() => _isListening = true);
      // Uncomment and use with speech_to_text package:
      // final available = await _speechToText.initialize();
      // if (available) {
      //   _speechToText.listen(
      //     onResult: (result) {
      //       setState(() => _voiceText = result.recognizedWords);
      //       _textController.text = _voiceText;
      //     },
      //   );
      // }

      // For demo: simulate voice input
      await Future.delayed(const Duration(seconds: 2));
      if (mounted && _isListening) {
        setState(() {
          _isListening = false;
          _textController.text = 'I was charged twice by my bank for the same transaction';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMessageList()),
            if (_isTyping) _buildTypingIndicator(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1230),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF3949AB).withOpacity(0.3), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3949AB).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF3949AB).withOpacity(0.5),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Bot avatar
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3949AB).withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const _SmallBotIcon(),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0A0E21), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'JusBot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'AI Legal Assistant • Online',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Disclaimer chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF7C4DFF).withOpacity(0.4),
              ),
            ),
            child: const Text(
              '⚖️ Legal AI',
              style: TextStyle(
                color: Color(0xFF9E7DFF),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Message list ──
  Widget _buildMessageList() {
    if (_messages.isEmpty && _showGreeting) {
      return _buildWelcomeState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _buildMessageBubble(msg, index);
      },
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: ScaleTransition(
        scale: _greetingAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3949AB).withOpacity(0.5),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const _SmallBotIcon(size: 80),
            ),
            const SizedBox(height: 16),
            const _TypingDots(),
          ],
        ),
      ),
    );
  }

  // ── Individual bubble ──
  Widget _buildMessageBubble(_ChatMessage msg, int index) {
    final isUser = msg.isUser;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(isUser ? 20 * (1 - value) : -20 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 8, bottom: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)],
                  ),
                ),
                child: const _SmallBotIcon(size: 30),
              ),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isUser
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
                        )
                      : null,
                  color: isUser ? null : const Color(0xFF141A3A),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  border: isUser
                      ? null
                      : Border.all(
                          color: const Color(0xFF3949AB).withOpacity(0.3),
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: (isUser
                              ? const Color(0xFF3949AB)
                              : Colors.black)
                          .withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildMessageText(msg.text, isUser),
              ),
            ),
            if (isUser)
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(left: 8, bottom: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3949AB).withOpacity(0.3),
                  border: Border.all(
                    color: const Color(0xFF5C6BC0).withOpacity(0.5),
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 16,
                  color: Color(0xFF9FA8DA),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageText(String text, bool isUser) {
    // Basic bold markdown support (**text**)
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontWeight: i.isOdd ? FontWeight.w700 : FontWeight.w400,
        ),
      ));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: isUser ? Colors.white : Colors.white.withOpacity(0.9),
          fontSize: 14.5,
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }

  // ── Typing indicator ──
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)],
              ),
            ),
            child: const _SmallBotIcon(size: 30),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF141A3A),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: const Color(0xFF3949AB).withOpacity(0.3),
              ),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  // ── Input area ──
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1230),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF3949AB).withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick suggestion chips
          if (_messages.length <= 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _suggestionChip('Banking fraud'),
                  _suggestionChip('Consumer complaint'),
                  _suggestionChip('Tenant rights'),
                  _suggestionChip('Salary dispute'),
                ],
              ),
            ),
          if (_messages.length <= 1) const SizedBox(height: 10),
          // Input row
          Row(
            children: [
              // Text field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141A3A),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFF3949AB).withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                          ),
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? '🎙️ Listening...'
                                : 'Describe your legal issue...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: _sendMessage,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Voice button
              GestureDetector(
                onTap: _toggleVoice,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF1A237E),
                    border: Border.all(
                      color: _isListening
                          ? const Color(0xFFEF5350)
                          : const Color(0xFF3949AB),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening
                                ? const Color(0xFFEF5350)
                                : const Color(0xFF3949AB))
                            .withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: _isListening ? 3 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              GestureDetector(
                onTap: () => _sendMessage(_textController.text),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3949AB), Color(0xFF7C4DFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3949AB).withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'JusBot provides legal guidance, not legal advice. Consult a lawyer for your specific case.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionChip(String label) {
    return GestureDetector(
      onTap: () => _sendMessage(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF3949AB).withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9FA8DA),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  _ChatMessage({
    required this.text,
    required this.isUser,
  }) : time = DateTime.now();
}

class _SmallBotIcon extends StatelessWidget {
  final double size;

  const _SmallBotIcon({this.size = 44});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SmallBotPainter(),
      size: Size(size, size),
    );
  }
}

class _SmallBotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 56; // scale factor
    final white = Paint()..color = Colors.white;
    final accent = Paint()..color = const Color(0xFF7C4DFF);

    // Head
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, cy + 1 * s), width: 28 * s, height: 24 * s),
      Radius.circular(8 * s),
    );
    canvas.drawRRect(headRect, white);

    // Eyes
    canvas.drawCircle(Offset(cx - 6 * s, cy - 1 * s), 4 * s, accent);
    canvas.drawCircle(Offset(cx - 6 * s, cy - 1 * s), 2 * s, white);
    canvas.drawCircle(Offset(cx + 6 * s, cy - 1 * s), 4 * s, accent);
    canvas.drawCircle(Offset(cx + 6 * s, cy - 1 * s), 2 * s, white);

    // Smile
    final smilePath = Path();
    smilePath.moveTo(cx - 6 * s, cy + 5 * s);
    smilePath.quadraticBezierTo(cx, cy + 9 * s, cx + 6 * s, cy + 5 * s);
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = const Color(0xFF7C4DFF)
        ..strokeWidth = 2.0 * s
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Antenna
    canvas.drawLine(
      Offset(cx, cy - 12 * s),
      Offset(cx, cy - 17 * s),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2 * s
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cx, cy - 18 * s), 2.5 * s, accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3.0;
            final phase = ((_ctrl.value - delay) % 1.0 + 1.0) % 1.0;
            final t = math.sin(phase * math.pi);
            return Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                  const Color(0xFF5C6BC0).withOpacity(0.4),
                  const Color(0xFF7C4DFF),
                  t,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}