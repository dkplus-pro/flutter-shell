import 'package:flutter/material.dart';

/// Visual accent used for a status pill in the order sheet (PRD 9):
/// purple primary for newly placed/reserved, gold for in-delivery, green for
/// delivered and neutral grey for rated.
///
/// Local stopgap constants until `HotelColors` tokens land in `app_ui`;
/// gold follows PRD 9 (`#C9A25E`).
const Color _orderPurple = Color(0xFF7C5CBF);
const Color _orderGold = Color(0xFFC9A25E);
const Color _orderGreen = Color(0xFF2E9E6B);
const Color _orderGrey = Color(0xFF8E8E93);

/// Lifecycle of a hotel order/service entry shown in the order sheet.
enum HotelOrderSheetStatus { placed, delivering, delivered, reserved, rated }

/// Pill background opacity applied to [hotelOrderSheetStatusColor].
const double _pillBackgroundAlpha = 0.12;

/// Accent color for a [HotelOrderSheetStatus], following PRD 9: purple primary
/// for placed/reserved, gold accent for in-delivery, green for delivered and a
/// neutral grey for rated entries.
Color hotelOrderSheetStatusColor(HotelOrderSheetStatus status) {
  switch (status) {
    case HotelOrderSheetStatus.placed:
    case HotelOrderSheetStatus.reserved:
      return _orderPurple;
    case HotelOrderSheetStatus.delivering:
      return _orderGold;
    case HotelOrderSheetStatus.delivered:
      return _orderGreen;
    case HotelOrderSheetStatus.rated:
      return _orderGrey;
  }
}

/// Fallback icon for a [HotelOrderSheetStatus] when the item carries no icon.
IconData _statusIcon(HotelOrderSheetStatus status) {
  switch (status) {
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

  /// Timestamp text rendered under the subtitle.
  final String timeText;

  /// Optional leading icon; falls back to a status-specific icon.
  final IconData? icon;
}

/// Shows the hotel order bottom sheet (PRD 6.3, D11).
///
/// The sheet is a read-only modal: rows cannot be tapped and closing the sheet
/// simply pops the route. Returns when the sheet has been dismissed.
Future<void> showHotelOrderSheet(
  BuildContext context, {
  required List<HotelOrderSheetItem> items,
  required String title,
  required String emptyText,
}) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (context) =>
        _HotelOrderSheetView(items: items, title: title, emptyText: emptyText),
  );
}

class _HotelOrderSheetView extends StatelessWidget {
  const new({
    required this.items,
    required this.title,
    required this.emptyText,
  });

  final List<HotelOrderSheetItem> items;
  final String title;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F1F24),
                  ),
                ),
              ),
            ),
            Flexible(
              child: items.isEmpty
                  ? _OrderSheetEmpty(emptyText: emptyText)
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final item in items) _OrderSheetRow(item: item),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
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
        color: const Color(0xFFC7C7CC),
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
            color: _orderGrey.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            emptyText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: _orderGrey),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderIcon(
            icon: item.icon ?? _statusIcon(item.status),
            accent: accent,
          ),
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
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F1F24),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B6B70),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.timeText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _StatusPill(label: item.statusLabel, accent: accent),
          ),
        ],
      ),
    );
  }
}

class _OrderIcon extends StatelessWidget {
  const new({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: accent),
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
        borderRadius: BorderRadius.circular(999),
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
