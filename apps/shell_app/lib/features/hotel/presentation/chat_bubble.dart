import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';

/// Grey-white concierge avatar placeholder.
class ChatAvatar extends StatelessWidget {
  const new({required this.semanticLabel, super.key});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: HotelColors.gold.withValues(alpha: 0.2),
        child: const Icon(
          Icons.support_agent,
          size: 18,
          color: HotelColors.primary,
        ),
      ),
    );
  }
}

/// A single message bubble. Guest messages sit right on the purple primary
/// color; concierge messages sit left on a white surface next to the avatar.
class ChatBubble extends StatelessWidget {
  const new({
    required this.role,
    required this.text,
    this.avatarSemanticLabel = '',
    super.key,
  });

  final MessageRole role;
  final String text;

  /// Accessibility label for the concierge avatar placeholder.
  final String avatarSemanticLabel;

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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              height: 1.4,
              fontSize: 15,
            ),
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
            decoration: BoxDecoration(
              color: HotelColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: HotelColors.textPrimary,
                height: 1.4,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Day separator line ("today …") above the first message.
class ChatDateSeparator extends StatelessWidget {
  const new({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _SeparatorLine()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            label,
            style: const TextStyle(
              color: HotelColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        const Expanded(child: _SeparatorLine()),
      ],
    );
  }
}

class _SeparatorLine extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: HotelColors.gold.withValues(alpha: 0.4),
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
      child: Text(
        label,
        style: const TextStyle(
          color: HotelColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}
