/// Resolves scripted reply keys and order copy to localized strings.
///
/// The data layer stores keys/enums only; every value must have a matching
/// ARB entry in both languages, enforced by the exhaustive switches.
library;

import 'package:fluttershell/features/hotel/data/amenity_catalog.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/features/hotel/data/hotel_order.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

Amenity? _amenityFromName(String? name) {
  for (final value in Amenity.values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}

/// Localized amenity display name.
String amenityName(AppLocalizations l10n, Amenity amenity) {
  return switch (amenity) {
    Amenity.slippers => l10n.amenitySlippers,
    Amenity.toiletries => l10n.amenityToiletries,
    Amenity.towels => l10n.amenityTowels,
    Amenity.water => l10n.amenityWater,
  };
}

/// Localized amenity measure word (双/套/条/瓶).
String amenityUnit(AppLocalizations l10n, Amenity amenity) {
  return switch (amenity) {
    Amenity.slippers => l10n.unitSlippers,
    Amenity.toiletries => l10n.unitToiletries,
    Amenity.towels => l10n.unitTowels,
    Amenity.water => l10n.unitWater,
  };
}

/// Text of a scripted concierge reply with its params.
String resolveConciergeCopy(
  AppLocalizations l10n,
  ScriptedReply reply,
  Map<String, String> params,
) {
  return switch (reply) {
    ScriptedReply.welcome => l10n.chatWelcome(params['room'] ?? ''),
    ScriptedReply.askQuantity => () {
      final amenity = _amenityFromName(params['amenity']);
      return l10n.chatAskQuantity(
        amenity == null ? '' : amenityName(l10n, amenity),
        amenity == null ? '' : amenityUnit(l10n, amenity),
      );
    }(),
    ScriptedReply.quantityInvalid => l10n.chatQuantityInvalid,
    ScriptedReply.cancelAck => l10n.chatCancelAck,
    ScriptedReply.askWakeupTime => l10n.chatAskWakeupTime,
    ScriptedReply.askLateCheckoutTime => l10n.chatAskLateCheckoutTime,
    ScriptedReply.timeChipsPrompt => l10n.chatTimeChipsPrompt,
    ScriptedReply.wifiAnswer => l10n.chatWifiAnswer(
      params['ssid'] ?? '',
      params['password'] ?? '',
    ),
    ScriptedReply.breakfastAnswer => l10n.chatBreakfastAnswer,
    ScriptedReply.wakeupAlreadyBooked => l10n.chatWakeupAlreadyBooked,
    ScriptedReply.lateCheckoutAlreadyRequested =>
      l10n.chatLateCheckoutAlreadyRequested,
    ScriptedReply.fallback => l10n.chatFallback,
  };
}

/// Localized title of an order (amenity name or the reserved service).
String orderTitle(AppLocalizations l10n, HotelOrder order) {
  final amenity = order.amenity;
  if (order.kind == OrderKind.amenity && amenity != null) {
    return amenityName(l10n, amenity);
  }
  return switch (order.kind) {
    OrderKind.wakeup => l10n.orderWakeupTitle,
    OrderKind.lateCheckout => l10n.orderLateCheckoutTitle,
    OrderKind.amenity => '',
  };
}

/// Status badge label.
String orderStatusLabel(AppLocalizations l10n, HotelOrder order) {
  return switch (order.status) {
    OrderStatus.pending => l10n.orderStatusPending,
    OrderStatus.placed => l10n.orderStatusPlaced,
    OrderStatus.delivering => l10n.orderStatusDelivering,
    OrderStatus.delivered => l10n.orderStatusDelivered,
    OrderStatus.rated => l10n.orderStatusRated(order.rating ?? 0),
    OrderStatus.reserved => l10n.orderStatusReserved,
  };
}

/// Progress hint under the status badge.
String orderProgressLabel(
  AppLocalizations l10n,
  HotelOrder order,
  String room,
) {
  return switch (order.status) {
    OrderStatus.placed => l10n.orderProgressPlaced,
    OrderStatus.delivering => l10n.orderProgressDelivering(room),
    OrderStatus.delivered => l10n.orderProgressDelivered,
    OrderStatus.pending || OrderStatus.rated || OrderStatus.reserved => '',
  };
}

/// Slot summary of a reservation (day + time + room).
String orderSlotSummary(AppLocalizations l10n, HotelOrder order, String room) {
  final time = order.slotTime ?? '';
  return switch (order.kind) {
    OrderKind.wakeup => l10n.orderWakeupSummary(
      order.nextDay ? l10n.dayTomorrow : l10n.dayToday,
      time,
      room,
    ),
    OrderKind.lateCheckout => l10n.orderLateCheckoutSummary(time),
    OrderKind.amenity => '',
  };
}
