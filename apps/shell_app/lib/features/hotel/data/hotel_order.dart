import 'package:fluttershell/features/hotel/data/amenity_catalog.dart';

/// Service category of an order (PRD 8).
enum OrderKind { amenity, wakeup, lateCheckout }

/// Lifecycle states of an order card (PRD 6.3).
///
/// Amenity: pending -> placed -> delivering -> delivered -> rated.
/// Reservation (wakeup / lateCheckout): pending -> reserved (terminal).
enum OrderStatus { pending, placed, delivering, delivered, rated, reserved }

/// One structured order behind an order-card chat message.
///
/// PRD 8 models `items[(nameKey, qty)]`; every demo flow produces exactly
/// one item per order, so the single `amenity` + `quantity` pair keeps the
/// model honest without a list wrapper.
class HotelOrder {
  const new({
    required this.id,
    required this.kind,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.amenity,
    this.quantity = 1,
    this.slotTime,
    this.nextDay = false,
    this.rating,
  });

  factory fromJson(Map<String, Object?> json) {
    final amenityName = json['amenity'] as String?;
    return HotelOrder(
      id: json['id']! as String,
      kind: OrderKind.values.byName(json['kind']! as String),
      status: OrderStatus.values.byName(json['status']! as String),
      createdAt: DateTime.parse(json['createdAt']! as String),
      updatedAt: DateTime.parse(json['updatedAt']! as String),
      amenity: amenityName == null ? null : Amenity.values.byName(amenityName),
      quantity: json['quantity'] as int? ?? 1,
      slotTime: json['slotTime'] as String?,
      nextDay: json['nextDay'] as bool? ?? false,
      rating: json['rating'] as int?,
    );
  }

  /// Unique, stable id; referenced by the order-card chat message.
  final String id;
  final OrderKind kind;

  /// Set only for [OrderKind.amenity].
  final Amenity? amenity;

  /// Item count (1-9) for amenity orders.
  final int quantity;

  /// Normalized `HH:mm` slot for reservation orders.
  final String? slotTime;

  /// True when the slot refers to tomorrow (wake-up default, PRD 7.1).
  final bool nextDay;
  final OrderStatus status;

  /// Submitted star rating; non-null only in the `rated` terminal state.
  final int? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Confirmed orders are immutable (PRD 6.3): the stepper and confirm
  /// button disappear and quantity never changes afterwards.
  bool get isConfirmed => status != OrderStatus.pending;

  HotelOrder copyWith({
    OrderStatus? status,
    int? quantity,
    int? rating,
    DateTime? updatedAt,
  }) {
    return HotelOrder(
      id: id,
      kind: kind,
      amenity: amenity,
      quantity: quantity ?? this.quantity,
      slotTime: slotTime,
      nextDay: nextDay,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'kind': kind.name,
    'amenity': amenity?.name,
    'quantity': quantity,
    'slotTime': slotTime,
    'nextDay': nextDay,
    'status': status.name,
    'rating': rating,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
