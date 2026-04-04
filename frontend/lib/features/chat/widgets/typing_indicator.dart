import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Typing Indicator Widget - Shows animated dots when someone is typing
class TypingIndicator extends StatefulWidget {
  final bool isTyping;
  final String typingName;
  final Duration animationDuration;

  const TypingIndicator({
    Key? key,
    required this.isTyping,
    this.typingName = 'Someone',
    this.animationDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    if (widget.isTyping) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTyping && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!widget.isTyping && _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTyping) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.typingName} ',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
            AnimatedDot(
              animationController: _animationController,
              delay: 0.0,
            ),
            AnimatedDot(
              animationController: _animationController,
              delay: 0.1,
            ),
            AnimatedDot(
              animationController: _animationController,
              delay: 0.2,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual animated dot for typing indicator
class AnimatedDot extends StatelessWidget {
  final AnimationController animationController;
  final double delay;

  const AnimatedDot({
    Key? key,
    required this.animationController,
    required this.delay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(delay, delay + 0.3, curve: Curves.easeInOut),
        ),
      ),
      child: Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

/// Compact Typing Indicator - Minimal version in chat list
class CompactTypingIndicator extends StatefulWidget {
  final bool isTyping;

  const CompactTypingIndicator({
    Key? key,
    required this.isTyping,
  }) : super(key: key);

  @override
  State<CompactTypingIndicator> createState() =>
      _CompactTypingIndicatorState();
}

class _CompactTypingIndicatorState extends State<CompactTypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    if (widget.isTyping) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(CompactTypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTyping != oldWidget.isTyping) {
      if (widget.isTyping) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTyping) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.6, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                index * 0.15,
                0.45 + (index * 0.15),
                curve: Curves.easeInOut,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.muted,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Large Typing Indicator - Takes up space in conversation
class LargeTypingIndicator extends StatefulWidget {
  final String senderName;
  final bool isTyping;

  const LargeTypingIndicator({
    Key? key,
    this.senderName = 'User',
    required this.isTyping,
  }) : super(key: key);

  @override
  State<LargeTypingIndicator> createState() => _LargeTypingIndicatorState();
}

class _LargeTypingIndicatorState extends State<LargeTypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    if (widget.isTyping) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(LargeTypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTyping && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isTyping && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTyping) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                '${widget.senderName} is typing',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return ScaleTransition(
                    scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Interval(
                          index * 0.2,
                          0.6 + (index * 0.2),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
