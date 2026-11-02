import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';

/// A single message bubble. Guest messages sit right on the purple primary
/// color; concierge messages sit left on a white surface. Both are 16-radius
/// rounded rectangles without tails (docs/06 §3.2) and no avatar — the
/// transcript stays compact and the time chips under a prompt line up with
/// the bubble edge.
class ChatBubble extends StatelessWidget {
  const new({required this.role, required this.text, this.content, super.key});

  final MessageRole role;
  final String text;

  /// Optional concierge bubble content rendered instead of [text] (e.g. the
  /// typewriter reveal). Guest bubbles always render [text].
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    const maxRatio = 0.78;
    final maxWidth = MediaQuery.sizeOf(context).width * maxRatio;
    final role = this.role;
    if (role == MessageRole.guest) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: HotelColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            boxShadow: HotelShadows.bubble,
          ),
          child: Text(
            text,
            style: HotelTypography.body.copyWith(color: Colors.white),
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: HotelColors.surface,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          boxShadow: HotelShadows.bubble,
        ),
        child: content ?? Text(text, style: HotelTypography.body),
      ),
    );
  }
}

/// Whole timestamp separator above the first message
/// (`yyyy-MM-dd HH:mm`, docs/06 §3.2): plain centered grey copy, no lines.
class ChatDateSeparator extends StatelessWidget {
  const new({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: HotelTypography.sub.copyWith(fontSize: 12)),
    );
  }
}

/// Inline `HH:mm` timestamp between two same-side messages more than five
/// minutes apart.
class ChatTimestamp extends StatelessWidget {
  const new({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: HotelTypography.sub.copyWith(fontSize: 12)),
    );
  }
}
