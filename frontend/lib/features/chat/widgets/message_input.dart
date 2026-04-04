import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

/// Message Input Widget - Text input and send button ONLY
/// Per strict rules: No attachment buttons, camera, emoji picker, etc.
class MessageInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final String hintText;
  final bool enabled;

  const MessageInputWidget({
    Key? key,
    required this.onSendMessage,
    this.hintText = 'Type a message...',
    this.enabled = true,
  }) : super(key: key);

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  late TextEditingController _controller;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {
      _isComposing = _controller.text.trim().isNotEmpty;
    });
  }

  void _handleSendMessage() {
    if (_controller.text.trim().isNotEmpty && widget.enabled) {
      widget.onSendMessage(_controller.text.trim());
      _controller.clear();
      setState(() {
        _isComposing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              maxLines: null,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.muted,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: AppColors.accentBlue,
                    width: 2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.muted,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: _isComposing && widget.enabled
                ? _handleSendMessage
                : null,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: _isComposing && widget.enabled
                    ? AppColors.accentGradient
                    : LinearGradient(
                        colors: [
                          AppColors.accentGradient.colors[0].withOpacity(0.3),
                          AppColors.accentGradient.colors[1].withOpacity(0.3),
                        ],
                      ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: _isComposing && widget.enabled
                    ? Colors.white
                    : AppColors.muted,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple Message Input - Minimal version
class SimpleMessageInput extends StatefulWidget {
  final Function(String) onSend;
  final TextEditingController? controller;

  const SimpleMessageInput({
    Key? key,
    required this.onSend,
    this.controller,
  }) : super(key: key);

  @override
  State<SimpleMessageInput> createState() => _SimpleMessageInputState();
}

class _SimpleMessageInputState extends State<SimpleMessageInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: AppColors.card,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Message...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              style: AppTextStyles.body,
            ),
          ),
          IconButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                widget.onSend(_controller.text);
                _controller.clear();
              }
            },
            icon: const Icon(Icons.send),
            color: AppColors.accentBlue,
          ),
        ],
      ),
    );
  }
}

/// Message Composer - Message text field with formatting
class MessageComposer extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback? onFocused;
  final bool enabled;

  const MessageComposer({
    Key? key,
    required this.onSubmit,
    this.onFocused,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  late FocusNode _focusNode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();

    _focusNode.addListener(_handleFocus);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (_focusNode.hasFocus && widget.onFocused != null) {
      widget.onFocused!();
    }
  }

  void _handleSubmit() {
    if (_controller.text.trim().isNotEmpty && widget.enabled) {
      widget.onSubmit(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          12,
          8,
          12,
          MediaQuery.of(context).viewInsets.bottom + 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Type message...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.muted,
                  ),
                  fillColor: AppColors.card,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.enabled ? _handleSubmit : null,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: widget.enabled
                        ? AppColors.accentGradient
                        : LinearGradient(
                            colors: [
                              AppColors.accentGradient.colors[0]
                                  .withOpacity(0.3),
                              AppColors.accentGradient.colors[1]
                                  .withOpacity(0.3),
                            ],
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: widget.enabled ? Colors.white : AppColors.muted,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
