import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttershell/features/hotel/application/hotel_chat_providers.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

/// Profile tab restyled as a decorative mock (docs/06 §3.4, P3): avatar +
/// name header, a member-card style gradient banner and an icon grid — all
/// purely visual. Tapping anywhere shows the "not available yet" toast.
class ProfilePage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final room = ref.watch(hotelGuestProfileProvider).roomNo;
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showNotAvailable(context, l10n),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _ProfileHeader(l10n: l10n, room: room),
              const SizedBox(height: AppSpacing.md),
              _MemberBanner(l10n: l10n),
              const SizedBox(height: AppSpacing.md),
              _ToolGridCard(
                tiles: [
                  (Icons.receipt_long_outlined, l10n.profileTileOrders),
                  (Icons.favorite_border, l10n.profileTileFavorites),
                  (Icons.settings_outlined, l10n.profileTileSettings),
                  (Icons.headset_mic_outlined, l10n.profileTileSupport),
                ],
              ),
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

/// Avatar + name + room badge header (mock guest binding, D8).
class _ProfileHeader extends StatelessWidget {
  const new({required this.l10n, required this.room});

  final AppLocalizations l10n;
  final String room;

  @override
  Widget build(BuildContext context) {
    final badge = l10n.hotelRoomBadge(room, l10n.hotelMockGuestName);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: HotelColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 28,
              color: HotelColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.hotelMockGuestName, style: HotelTypography.title),
                const SizedBox(height: 2),
                Text(badge, style: HotelTypography.sub),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Member-card style gradient banner (docs/06 §3.4; decorative demo copy
/// only — no external brand membership wording).
class _MemberBanner extends StatelessWidget {
  const new({required this.l10n});

  final AppLocalizations l10n;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileMemberTitle,
            style: HotelTypography.title.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.profileMemberSubtitle,
            style: HotelTypography.sub.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// White card with a 4-tile icon grid (docs/06 §3.4).
class _ToolGridCard extends StatelessWidget {
  const new({required this.tiles});

  final List<(IconData, String)> tiles;

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
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: HotelColors.tileGray,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tiles[i].$1,
                      size: 22,
                      color: HotelColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tiles[i].$2,
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
          ],
        ],
      ),
    );
  }
}
