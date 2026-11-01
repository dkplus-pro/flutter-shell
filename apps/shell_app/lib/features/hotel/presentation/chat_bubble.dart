import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';

/// White concierge avatar with a hairline border and the purple headset
/// line icon (docs/06 §3.2; no mascot artwork).
class ChatAvatar extends StatelessWidget {
  const new({required this.semanticLabel, super.key});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: HotelColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: HotelColors.divider, width: 0.5),
        ),
        child: const Icon(
          Icons.headset_mic_outlined,
          size: 16,
          color: HotelColors.primary,
        ),
      ),
    );
  }
}

/// A single message bubble. Guest messages sit right on the purple primary
/// color; concierge messages sit left on a white surface next to the avatar.
/// Both are 16-radius rounded rectangles without tails (docs/06 §3.2).
class ChatBubble extends StatelessWidget {
  const new({
    required this.role,
    required this.text,
    this.avatarSemanticLabel = '',
    this.content,
    super.key,
  });

  final MessageRole role;
  final String text;

  /// Accessibility label for the concierge avatar placeholder.
  final String avatarSemanticLabel;

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
          ),
          child: Text(
            text,
            style: HotelTypography.body.copyWith(color: Colors.white),
          ),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChatAvatar(semanticLabel: avatarSemanticLabel),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: HotelColors.surface,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: content ?? Text(text, style: HotelTypography.body),
          ),
        ),
      ],
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
