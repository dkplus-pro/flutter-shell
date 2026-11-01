import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttershell/core/router/app_router.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Home tab restyled as a decorative mock (docs/06 §3.4, P3): purple gradient
/// greeting header, fake search card and an icon grid — all purely visual.
/// Tapping anywhere shows the "not available yet" toast; the bridge demo
/// entry stays reachable.
class HomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final guestName = l10n.hotelMockGuestName;
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showNotAvailable(context, l10n),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _GreetingHeader(greeting: l10n.homeGreeting(guestName)),
              const SizedBox(height: AppSpacing.md),
              _FakeSearchCard(l10n: l10n),
              const SizedBox(height: AppSpacing.md),
              _ServiceGridCard(
                title: l10n.homeServicesTitle,
                tiles: [
                  (Icons.room_service_outlined, l10n.homeTileDeliver),
                  (Icons.alarm, l10n.homeTileWakeup),
                  (Icons.event_available, l10n.homeTileLateCheckout),
                  (Icons.receipt_long_outlined, l10n.homeTileOrders),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _BridgeDemoCard(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotAvailable(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.placeholderNotAvailable)));
  }
}

/// Purple gradient welcome header (docs/06 §3.4).
class _GreetingHeader extends StatelessWidget {
  const new({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HotelDimens.cardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HotelColors.primary, HotelColors.primaryDeep],
        ),
      ),
      child: Text(
        greeting,
        style: HotelTypography.titleL.copyWith(color: Colors.white),
      ),
    );
  }
}

/// Decorative search card: a fake input capsule plus a full-round purple
/// button (docs/06 §3.4). No interaction logic.
class _FakeSearchCard extends StatelessWidget {
  const new({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: HotelColors.surface,
        borderRadius: BorderRadius.circular(HotelDimens.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: HotelColors.inputPill,
                borderRadius: BorderRadius.circular(HotelDimens.capsuleRadius),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    size: 18,
                    color: HotelColors.textHint,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.homeSearchHint,
                    style: const TextStyle(
                      fontSize: 13,
                      color: HotelColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: HotelColors.primary,
              borderRadius: BorderRadius.circular(HotelDimens.capsuleRadius),
            ),
            child: Text(
              l10n.homeSearchButton,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// White card with a section title and a 4-tile icon grid.
class _ServiceGridCard extends StatelessWidget {
  const new({required this.title, required this.tiles});

  final String title;
  final List<(IconData, String)> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: HotelColors.surface,
        borderRadius: BorderRadius.circular(HotelDimens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: HotelTypography.title),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _GridTile(icon: tiles[i].$1, label: tiles[i].$2),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _GridTile extends StatelessWidget {
  const new({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: HotelColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 22, color: HotelColors.primary),
        ),
        const SizedBox(height: AppSpacing.sm),
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
    );
  }
}

/// The bridge demo stays reachable from the home mock (PRD 4).
class _BridgeDemoCard extends StatelessWidget {
  const new({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HotelColors.surface,
        borderRadius: BorderRadius.circular(HotelDimens.cardRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(HotelDimens.cardRadius),
        onTap: () => context.push(AppRoutes.bridgeDemo),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: HotelColors.tileGray,
                  borderRadius: BorderRadius.circular(
                    HotelDimens.iconBlockRadius,
                  ),
                ),
                child: const Icon(
                  Icons.api,
                  size: 20,
                  color: HotelColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.openBridgeDemo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: HotelColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: HotelColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
