import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

/// Quick-service panel shown above the input bar (PRD 6.4, D7), restyled per
/// docs/06 §3.2: white card with 20-radius top corners, a "quick services"
/// section title and small `tileGray` tiles whose icons sit on `primarySoft`
/// circles; labels scale down with [FittedBox] instead of truncating.
/// Selecting an entry sends the matching preset message as the guest.
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
      decoration: const BoxDecoration(
        color: HotelColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(HotelDimens.panelTopRadius),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(l10n.quickPanelTitle, style: HotelTypography.titleL),
          ),
          GridView.count(
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
        borderRadius: BorderRadius.circular(HotelDimens.tileRadius),
        child: Container(
          decoration: BoxDecoration(
            color: HotelColors.tileGray,
            borderRadius: BorderRadius.circular(HotelDimens.tileRadius),
          ),
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: HotelColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: HotelColors.primary),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Scale instead of ellipsis so entries like "Late check-out"
              // stay fully visible (docs/06 §3.2).
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HotelColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
