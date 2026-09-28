import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/ai_tour_guide_service.dart';





class GeneralAITourGuideScreen extends StatefulWidget {
  const GeneralAITourGuideScreen({super.key});

  @override
  State<GeneralAITourGuideScreen> createState() =>
      _GeneralAITourGuideScreenState();
}

class _GeneralAITourGuideScreenState extends State<GeneralAITourGuideScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focus = FocusNode();

  final List<_Msg> _messages = [
    _Msg(
      role: _Role.bot,
      text:
          "Hi! I'm your Alexandria tourism expert. Ask me anything about "
          'places to visit, food, history, hidden gems, or tips for getting '
          'around the city.',
    ),
  ];
  bool _busy = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() {
      _messages.add(_Msg(role: _Role.user, text: text));
      _busy = true;
    });
    _input.clear();
    _scrollToBottom();
    try {
      final reply = await AITourGuideService.askAlexandria(text);
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(role: _Role.bot, text: reply));
        _busy = false;
      });
      _scrollToBottom();
    } on GeminiApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(
          role: _Role.bot,
          text: 'Could not reach the AI right now (${e.message}). Try again '
                'in a moment.',
        ));
        _busy = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(
          role: _Role.bot,
          text: 'Something went wrong: $e',
        ));
        _busy = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.travel_explore_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Alexandria AI Guide',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _Bubble(msg: _messages[i]),
            ),
          ),
          if (_busy)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Thinking about Alexandria...',
                    style: TextStyle(
                      color: context.textSec,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          _Composer(
            controller: _input,
            focusNode: _focus,
            busy: _busy,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

enum _Role { user, bot }

class _Msg {
  final _Role role;
  final String text;
  const _Msg({required this.role, required this.text});
}

class _Bubble extends StatelessWidget {
  final _Msg msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == _Role.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          if (!isUser) const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.transparent
                      : context.borderColor.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isUser ? Colors.white : context.textPri,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool busy;
  final Future<void> Function() onSend;
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.busy,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        12 + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(
          top: BorderSide(color: context.borderColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText:
                    'Ask about Alexandria — places, food, history...',
                filled: true,
                fillColor: context.bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                hintStyle: TextStyle(color: context.textSec),
              ),
              style: TextStyle(color: context.textPri),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              onPressed: busy ? null : () => onSend(),
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
