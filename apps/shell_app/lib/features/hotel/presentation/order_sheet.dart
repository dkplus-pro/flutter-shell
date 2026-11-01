import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Builds the sheet rows from live state; called on every relevant provider
/// change while the sheet is open so statuses stay in sync with the chat
/// cards (D11). The caller watches its providers inside the builder.
typedef HotelOrderSheetItemsBuilder = List<HotelOrderSheetItem> Function(
  WidgetRef ref,
);

/// Lifecycle of a hotel order/service entry shown in the order sheet.
///
/// `pending` covers not-yet-confirmed order cards; it renders with the
/// neutral grey family so the demo palette stays at four families (PRD 9).
enum HotelOrderSheetStatus {
  pending,
  placed,
  delivering,
  delivered,
  reserved,
  rated,
}

/// Pill background opacity applied to [hotelOrderSheetStatusColor]
/// (the "10% tint" of docs/06 §2.1, kept at 12% for the existing
/// component-test assertion).
const double _pillBackgroundAlpha = 0.12;

/// Accent color for a [HotelOrderSheetStatus], from the `HotelColors` tokens
/// (docs/06 §2.1): primary purple for placed/reserved, orange for in-delivery,
/// green for delivered and neutral grey for pending/rated entries.
Color hotelOrderSheetStatusColor(HotelOrderSheetStatus status) {
  switch (status) {
    case HotelOrderSheetStatus.pending:
    case HotelOrderSheetStatus.rated:
      return HotelColors.statusNeutral;
    case HotelOrderSheetStatus.placed:
    case HotelOrderSheetStatus.reserved:
      return HotelColors.statusPlaced;
    case HotelOrderSheetStatus.delivering:
      return HotelColors.statusDelivering;
    case HotelOrderSheetStatus.delivered:
      return HotelColors.statusDelivered;
  }
}

/// Fallback icon for a [HotelOrderSheetStatus] when the item carries no icon.
IconData _statusIcon(HotelOrderSheetStatus status) {
  switch (status) {
    case HotelOrderSheetStatus.pending:
      return Icons.schedule;
    case HotelOrderSheetStatus.placed:
      return Icons.receipt_long;
    case HotelOrderSheetStatus.delivering:
      return Icons.local_shipping;
    case HotelOrderSheetStatus.delivered:
      return Icons.check_circle;
    case HotelOrderSheetStatus.reserved:
      return Icons.event_available;
    case HotelOrderSheetStatus.rated:
      return Icons.reviews;
  }
}

/// Read-only order/service entry rendered as a row in the order sheet.
///
/// All user-visible strings are injected by the caller; the widget itself
/// contains no copy.
class HotelOrderSheetItem {
  /// Creates a read-only sheet row description.
  const new({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.status,
    required this.timeText,
    this.icon,
  });

  /// Stable identifier of the order or service request.
  final String id;

  /// Primary row title, e.g. the item name.
  final String title;

  /// Secondary description line below [title].
  final String subtitle;

  /// Short status copy shown inside the colored pill.
  final String statusLabel;

  /// Status driving the pill color and the fallback icon.
  final HotelOrderSheetStatus status;

  /// Timestamp text rendered on the trailing side under the status pill.
  final String timeText;

  /// Optional leading icon; falls back to a status-specific icon.
  final IconData? icon;
}

/// Shows the hotel order bottom sheet (PRD 6.3, D11).
///
/// The sheet is a read-only modal: rows cannot be tapped and closing the sheet
/// simply pops the route. Returns when the sheet has been dismissed. Pass
/// [liveItems] to keep the rows in sync with the caller's state while the
/// sheet is open; without it [items] is a static snapshot.
Future<void> showHotelOrderSheet(
  BuildContext context, {
  required List<HotelOrderSheetItem> items,
  required String title,
  required String emptyText,
  HotelOrderSheetItemsBuilder? liveItems,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: HotelColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(HotelDimens.panelTopRadius),
      ),
    ),
    isScrollControlled: true,
    builder: (context) => _HotelOrderSheetView(
      items: items,
      title: title,
      emptyText: emptyText,
      liveItems: liveItems,
    ),
  );
}

class _HotelOrderSheetView extends StatelessWidget {
  const new({
    required this.items,
    required this.title,
    required this.emptyText,
    this.liveItems,
  });

  final List<HotelOrderSheetItem> items;
  final String title;
  final String emptyText;
  final HotelOrderSheetItemsBuilder? liveItems;

  @override
  Widget build(BuildContext context) {
    final rows = liveItems == null
        ? _rows(context, items)
        : Consumer(
            builder: (context, ref, _) => _rows(context, liveItems!(ref)),
          );
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const _DragHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title, style: HotelTypography.title),
              ),
            ),
            Flexible(child: rows),
          ],
        ),
      ),
    );
  }

  Widget _rows(BuildContext context, List<HotelOrderSheetItem> current) {
    if (current.isEmpty) {
      return _OrderSheetEmpty(emptyText: emptyText);
    }
    final children = <Widget>[];
    for (var i = 0; i < current.length; i++) {
      if (i > 0) {
        children.add(const _RowDivider());
      }
      children.add(_OrderSheetRow(item: current[i]));
    }
    return SingleChildScrollView(child: Column(children: children));
  }
}

/// 0.5px hairline between sheet rows, inset to clear the icon block
/// (docs/06 §3.3).
class _RowDivider extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: HotelDimens.hairline,
      margin: const EdgeInsets.only(left: 68),
      color: HotelColors.divider,
    );
  }
}

class _DragHandle extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: HotelColors.starEmpty,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _OrderSheetEmpty extends StatelessWidget {
  const new({required this.emptyText});

  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long,
            size: 40,
            color: HotelColors.textSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            emptyText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: HotelColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSheetRow extends StatelessWidget {
  const new({required this.item});

  final HotelOrderSheetItem item;

  @override
  Widget build(BuildContext context) {
    final accent = hotelOrderSheetStatusColor(item.status);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderIcon(icon: item.icon ?? _statusIcon(item.status)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: HotelColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HotelTypography.sub,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusPill(label: item.statusLabel, accent: accent),
              const SizedBox(height: 4),
              Text(
                item.timeText,
                style: HotelTypography.sub.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 40dp `tileGray` rounded-square icon block (docs/06 §3.3).
class _OrderIcon extends StatelessWidget {
  const new({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: HotelDimens.iconBlockSize,
      height: HotelDimens.iconBlockSize,
      decoration: BoxDecoration(
        color: HotelColors.tileGray,
        borderRadius: BorderRadius.circular(HotelDimens.iconBlockRadius),
      ),
      child: Icon(icon, size: 20, color: HotelColors.primary),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const new({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: _pillBackgroundAlpha),
        borderRadius: BorderRadius.circular(HotelDimens.capsuleRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
      ),
    );
  }
}
