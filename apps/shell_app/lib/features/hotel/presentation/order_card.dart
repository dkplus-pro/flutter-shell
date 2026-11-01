import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttershell/features/hotel/data/amenity_catalog.dart';
import 'package:fluttershell/features/hotel/data/hotel_order.dart';
import 'package:fluttershell/features/hotel/presentation/concierge_copy.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

/// Icon for an amenity or reservation order (mock catalog, PRD 8).
IconData orderIcon(HotelOrder order) {
  final amenity = order.amenity;
  if (order.kind == OrderKind.amenity && amenity != null) {
    return switch (amenity) {
      Amenity.slippers => Icons.directions_walk,
      Amenity.toiletries => Icons.soap,
      Amenity.towels => Icons.checkroom,
      Amenity.water => Icons.local_drink,
    };
  }
  return switch (order.kind) {
    OrderKind.wakeup => Icons.alarm,
    OrderKind.lateCheckout => Icons.event_available,
    OrderKind.amenity => Icons.inventory_2_outlined,
  };
}

Color _statusColor(HotelOrder order) {
  return switch (order.status) {
    OrderStatus.pending => HotelColors.gold,
    OrderStatus.placed => HotelColors.gold,
    OrderStatus.delivering => HotelColors.primary,
    OrderStatus.delivered => HotelColors.statusDelivered,
    OrderStatus.rated => HotelColors.textSecondary,
    OrderStatus.reserved => HotelColors.gold,
  };
}

/// Structured order card inside the transcript (PRD 6.3).
///
/// Pending: stepper (1-9) + confirm button, editable until confirmed once.
/// Confirmed: status badge + progress copy; amenity cards expose the star
/// rating row after delivery (D12, minimal inline implementation).
class OrderCard extends StatefulWidget {
  const new({
    required this.order,
    required this.roomNo,
    required this.onConfirm,
    required this.onRate,
    super.key,
  });

  final HotelOrder order;
  final String roomNo;
  final void Function(String orderId, int quantity) onConfirm;
  final void Function(String orderId, int stars) onRate;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _quantity = widget.order.quantity;
  }

  void _step(int delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(1, 9);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final order = widget.order;
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: HotelColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(orderIcon(order), size: 20, color: HotelColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  orderTitle(l10n, order),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: HotelColors.textPrimary,
                  ),
                ),
              ),
              if (order.isConfirmed) _buildStatusBadge(l10n, order),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._buildBody(l10n, order),
        ],
      ),
    );
  }

  List<Widget> _buildBody(AppLocalizations l10n, HotelOrder order) {
    if (order.kind == OrderKind.amenity) {
      return _buildAmenityBody(l10n, order);
    }
    return [
      Text(
        orderSlotSummary(l10n, order, widget.roomNo),
        style: const TextStyle(color: HotelColors.textSecondary, fontSize: 13),
      ),
      if (!order.isConfirmed) ...[
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: HotelColors.primary),
            onPressed: () => widget.onConfirm(order.id, order.quantity),
            child: Text(l10n.orderReserveButton),
          ),
        ),
      ],
      if (order.status == OrderStatus.reserved)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            l10n.orderProgressReserved,
            style: const TextStyle(
              color: HotelColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildAmenityBody(AppLocalizations l10n, HotelOrder order) {
    return [
      if (order.isConfirmed)
        Text(
          l10n.orderQuantityLabel(order.quantity),
          style: const TextStyle(color: HotelColors.textPrimary, fontSize: 14),
        )
      else
        _buildStepper(l10n, order),
      const SizedBox(height: AppSpacing.xs),
      Text(
        l10n.orderDeliverTo(widget.roomNo),
        style: const TextStyle(color: HotelColors.textSecondary, fontSize: 13),
      ),
      if (!order.isConfirmed) ...[
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: HotelColors.primary),
            onPressed: () => widget.onConfirm(order.id, _quantity),
            child: Text(l10n.orderConfirmButton),
          ),
        ),
      ] else ...[
        const SizedBox(height: AppSpacing.xs),
        Text(
          orderProgressLabel(l10n, order, widget.roomNo),
          style: const TextStyle(
            color: HotelColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
      if (order.status == OrderStatus.delivered) _buildRatingRow(l10n, order),
      if (order.status == OrderStatus.rated)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Row(
            children: [
              const Icon(Icons.star, size: 16, color: HotelColors.star),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.orderStatusRated(order.rating ?? 0),
                style: const TextStyle(
                  color: HotelColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _buildStepper(AppLocalizations l10n, HotelOrder order) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          color: HotelColors.primary,
          tooltip: l10n.orderStepperMinusSemantic,
          onPressed: _quantity > 1 ? () => _step(-1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            '$_quantity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: HotelColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: HotelColors.primary,
          tooltip: l10n.orderStepperPlusSemantic,
          onPressed: _quantity < 9 ? () => _step(1) : null,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(AppLocalizations l10n, HotelOrder order) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _statusColor(order).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        orderStatusLabel(l10n, order),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _statusColor(order),
        ),
      ),
    );
  }

  /// Minimal inline star row (D12): five tappable stars, one tap submits.
  /// Will be replaced by the polished component in a later integration.
  Widget _buildRatingRow(AppLocalizations l10n, HotelOrder order) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ratingPrompt,
            style: const TextStyle(
              color: HotelColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Row(
            children: [
              for (var stars = 1; stars <= 5; stars++)
                GestureDetector(
                  onTap: () => widget.onRate(order.id, stars),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.star_border,
                      size: 26,
                      color: HotelColors.star,
                      semanticLabel: l10n.ratingStarSemantic(stars),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
