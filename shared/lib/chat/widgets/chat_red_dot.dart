import 'package:flutter/material.dart';
import 'package:shared/chat/config/chat_theme.dart';

/// Small red unread indicator (dot only, no count).
class ChatRedDot extends StatelessWidget {
  const ChatRedDot({super.key, this.size = 10});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: ChatTheme.trainerRed,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Wraps [child] with a top-right red dot when [show] is true.
class ChatRedDotBadge extends StatelessWidget {
  const ChatRedDotBadge({
    super.key,
    required this.child,
    required this.show,
  });

  final Widget child;
  final bool show;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: show,
      backgroundColor: ChatTheme.trainerRed,
      smallSize: 10,
      alignment: AlignmentDirectional.topEnd,
      child: child,
    );
  }
}
