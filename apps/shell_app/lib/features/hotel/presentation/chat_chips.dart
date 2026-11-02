import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Tappable quick-option chips under a concierge prompt (failed time parse
/// produces two suggestion chips, PRD 7.1). Tap sends the value as the
/// guest, so options must stay parseable by the slot parser. Styled as
/// grey capsules matching the reference chip language (docs/06 §1).
///
/// Chips are one-shot: once the prompt is answered or superseded, [enabled]
/// turns them into inert history so the same suggestion never fires twice.
class ChatChips extends StatelessWidget {
  const new({
    required this.options,
    required this.onSelect,
    this.enabled = true,
    super.key,
  });

  final List<String> options;
  final ValueChanged<String> onSelect;

  /// Whether the suggestions can still be tapped.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          Semantics(
            button: enabled,
            enabled: enabled,
            child: InkWell(
              onTap: enabled ? () => onSelect(option) : null,
              borderRadius: BorderRadius.circular(HotelDimens.capsuleRadius),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: HotelColors.tileGray,
                  borderRadius: BorderRadius.circular(
                    HotelDimens.capsuleRadius,
                  ),
                  boxShadow: HotelShadows.tile,
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 13,
                    color: enabled
                        ? HotelColors.primary
                        : HotelColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
