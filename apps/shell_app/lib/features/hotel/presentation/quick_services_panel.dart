import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

/// 2x4 quick-service grid shown above the input bar (PRD 6.4, D7). Selecting
/// an entry sends the matching preset message as the guest.
class QuickServicesPanel extends StatelessWidget {
  const new({required this.onSelect, super.key});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = <(IconData, String, String)>[
      (Icons.directions_walk, l10n.quickSlippers, l10n.presetSlippers),
      (Icons.soap, l10n.quickToiletries, l10n.presetToiletries),
      (Icons.checkroom, l10n.quickTowels, l10n.presetTowels),
      (Icons.local_drink, l10n.quickWater, l10n.presetWater),
      (Icons.alarm, l10n.quickWakeup, l10n.presetWakeup),
      (Icons.event_available, l10n.quickLateCheckout, l10n.presetLateCheckout),
      (Icons.wifi, l10n.quickWifi, l10n.presetWifi),
      (Icons.free_breakfast, l10n.quickBreakfast, l10n.presetBreakfast),
    ];
    return Container(
      width: double.infinity,
      color: HotelColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.1,
        children: [
          for (final (icon, label, preset) in entries)
            _QuickItem(
              icon: icon,
              label: label,
              preset: preset,
              onSelect: onSelect,
            ),
        ],
      ),
    );
  }
}

class _QuickItem extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.preset,
    required this.onSelect,
  });

  final IconData icon;
  final String label;
  final String preset;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: () => onSelect(preset),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: HotelColors.primary),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: HotelColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
