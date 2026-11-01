import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttershell/features/hotel/data/amenity_catalog.dart';
import 'package:fluttershell/features/hotel/data/hotel_order.dart';
import 'package:fluttershell/features/hotel/presentation/concierge_copy.dart';
import 'package:fluttershell/features/hotel/presentation/star_rating_bar.dart';
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

/// Status badge accent; mirrors the order sheet so both surfaces stay in
/// sync through the same [HotelColors] tokens (docs/06 §2.1).
Color _statusColor(HotelOrder order) {
  return switch (order.status) {
    OrderStatus.pending => HotelColors.statusNeutral,
    OrderStatus.placed => HotelColors.statusPlaced,
    OrderStatus.delivering => HotelColors.statusDelivering,
    OrderStatus.delivered => HotelColors.statusDelivered,
    OrderStatus.rated => HotelColors.statusNeutral,
    OrderStatus.reserved => HotelColors.statusPlaced,
  };
}

/// Structured order card inside the transcript (PRD 6.3), restyled per
/// docs/06 §3.3: `tileGray` icon block, bold name, status pill, hairline
/// divider, outlined stepper capsule and a full-width purple capsule CTA.
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
        borderRadius: BorderRadius.circular(HotelDimens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildIconBlock(order),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  orderTitle(l10n, order),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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

  Widget _buildIconBlock(HotelOrder order) {
    return Container(
      width: HotelDimens.iconBlockSize,
      height: HotelDimens.iconBlockSize,
      decoration: BoxDecoration(
        color: HotelColors.tileGray,
        borderRadius: BorderRadius.circular(HotelDimens.iconBlockRadius),
      ),
      child: Icon(orderIcon(order), size: 20, color: HotelColors.primary),
    );
  }

  List<Widget> _buildBody(AppLocalizations l10n, HotelOrder order) {
    if (order.kind == OrderKind.amenity) {
      return _buildAmenityBody(l10n, order);
    }
    return [
      Text(
        orderSlotSummary(l10n, order, widget.roomNo),
        style: HotelTypography.sub,
      ),
      if (!order.isConfirmed) ...[
        const SizedBox(height: AppSpacing.md),
        _buildCta(
          label: l10n.orderReserveButton,
          onPressed: () => widget.onConfirm(order.id, order.quantity),
        ),
      ],
      if (order.status == OrderStatus.reserved)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(l10n.orderProgressReserved, style: HotelTypography.sub),
        ),
    ];
  }

  List<Widget> _buildAmenityBody(AppLocalizations l10n, HotelOrder order) {
    return [
      if (order.isConfirmed)
        Text(
          l10n.orderQuantityLabel(order.quantity),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: HotelColors.textPrimary,
          ),
        )
      else
        _buildStepper(l10n, order),
      const SizedBox(height: AppSpacing.xs),
      Text(l10n.orderDeliverTo(widget.roomNo), style: HotelTypography.sub),
      if (!order.isConfirmed) ...[
        const SizedBox(height: AppSpacing.sm),
        _buildHairline(),
        const SizedBox(height: AppSpacing.sm),
        _buildCta(
          label: l10n.orderConfirmButton,
          onPressed: () => widget.onConfirm(order.id, _quantity),
        ),
      ] else ...[
        const SizedBox(height: AppSpacing.xs),
        Text(
          orderProgressLabel(l10n, order, widget.roomNo),
          style: HotelTypography.sub,
        ),
      ],
      if (order.status == OrderStatus.delivered) _buildRatingRow(l10n, order),
      if (order.status == OrderStatus.rated)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Row(
            children: [
              const Icon(Icons.star, size: 16, color: HotelColors.starGold),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.orderStatusRated(order.rating ?? 0),
                style: HotelTypography.sub,
              ),
            ],
          ),
        ),
    ];
  }

  /// Outlined circular stepper buttons inside the card (docs/06 §3.3).
  Widget _buildStepper(AppLocalizations l10n, HotelOrder order) {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove,
          tooltip: l10n.orderStepperMinusSemantic,
          onPressed: _quantity > 1 ? () => _step(-1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            '$_quantity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: HotelColors.textPrimary,
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          tooltip: l10n.orderStepperPlusSemantic,
          onPressed: _quantity < 9 ? () => _step(1) : null,
        ),
      ],
    );
  }

  Widget _buildCta({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: HotelColors.primary,
          shape: const StadiumBorder(),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHairline() {
    return Container(height: HotelDimens.hairline, color: HotelColors.divider);
  }

  Widget _buildStatusBadge(AppLocalizations l10n, HotelOrder order) {
    final accent = _statusColor(order);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(HotelDimens.capsuleRadius),
      ),
      child: Text(
        orderStatusLabel(l10n, order),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
      ),
    );
  }

  /// Star rating row shown after delivery (D12): one tap submits via
  /// [StarRatingBar]; the controller enforces the once-only rule.
  Widget _buildRatingRow(AppLocalizations l10n, HotelOrder order) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.ratingPrompt, style: HotelTypography.sub),
          StarRatingBar(
            rating: order.rating ?? 0,
            enabled: order.status == OrderStatus.delivered,
            onRated: (stars) => widget.onRate(order.id, stars),
            semanticsLabel: l10n.ratingBarSemantic,
          ),
        ],
      ),
    );
  }
}

/// Outlined circular step button (docs/06 §3.3).
class _StepButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: HotelColors.divider),
          ),
          child: Icon(
            icon,
            size: 18,
            color: onPressed == null
                ? HotelColors.textHint
                : HotelColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
