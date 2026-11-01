import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Tappable quick-option chips under a concierge prompt (failed time parse
/// produces two suggestion chips, PRD 7.1). Tap sends the value as the
/// guest, so options must stay parseable by the slot parser. Styled as
/// grey capsules matching the reference chip language (docs/06 §1).
class ChatChips extends StatelessWidget {
  const ChatChips({required this.options, required this.onSelect, super.key});

  final List<String> options;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          InkWell(
            onTap: () => onSelect(option),
            borderRadius: BorderRadius.circular(HotelDimens.capsuleRadius),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: HotelColors.tileGray,
                borderRadius: BorderRadius.circular(HotelDimens.capsuleRadius),
              ),
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 13,
                  color: HotelColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
