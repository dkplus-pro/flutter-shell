import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Tappable quick-option chips under a concierge prompt (failed time parse
/// produces two suggestion chips, PRD 7.1). Tap sends the value as the
/// guest, so options must stay parseable by the slot parser.
class ChatChips extends StatelessWidget {
  const new({required this.options, required this.onSelect, super.key});

  final List<String> options;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          ActionChip(label: Text(option), onPressed: () => onSelect(option)),
      ],
    );
  }
}
