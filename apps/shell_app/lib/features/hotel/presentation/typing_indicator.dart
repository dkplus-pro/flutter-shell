import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttershell/features/hotel/presentation/chat_bubble.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

/// "Typing" bubble shown while a concierge reply is being prepared
/// (PRD 6.2). Occupies one stream position and is never persisted.
class TypingIndicator extends StatefulWidget {
  const new({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.chatTyping,
      child: Row(
        children: [
          ChatAvatar(semanticLabel: l10n.conciergeAvatarSemantic),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 12,
            ),
            decoration: const BoxDecoration(
              color: HotelColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.xs),
                      _Dot(phase: (_controller.value * 3 - i).clamp(0.0, 1.0)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const new({required this.phase});

  /// 0..1 highlight phase of this dot within the pulse cycle.
  final double phase;

  @override
  Widget build(BuildContext context) {
    final opacity = 0.3 + 0.7 * (1 - (2 * phase - 1).abs());
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: HotelColors.textSecondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
