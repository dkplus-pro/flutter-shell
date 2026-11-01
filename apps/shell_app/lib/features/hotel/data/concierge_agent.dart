import 'package:fluttershell/features/hotel/data/amenity_catalog.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/features/hotel/data/hotel_order.dart';
import 'package:fluttershell/features/hotel/data/slot_parsers.dart';

/// Demo access data (PRD 7.2 S3); explicitly marked as demo copy in ARB.
abstract final class DemoAccess {
  static const String wifiSsid = 'Hotel-Guest';
  static const String wifiPassword = '12345678';
}

/// A slot-filling flow in progress, kept in the chat state (not persisted:
/// an interrupted flow simply restarts after relaunch).
class PendingSlot {
  const new({required this.kind, this.amenity});

  /// Order the flow will create once the slot is filled.
  final OrderKind kind;

  /// Item being ordered; set only when [kind] is [OrderKind.amenity].
  final Amenity? amenity;
}

/// One turn of guest input into the agent (PRD 7.4: swapping in a real LLM
/// later means another [ConciergeAgent] behind this same request/response).
class AgentRequest {
  const new({required this.input, required this.pending, required this.roomNo});

  /// Raw guest text; the agent normalizes it.
  final String input;

  /// Active slot-filling flow, if any.
  final PendingSlot? pending;
  final String roomNo;
}

/// Emitted side effects, applied by the chat controller in order.
sealed class AgentAction {
  const new();
}

/// A scripted concierge text bubble.
class SayAction extends AgentAction {
  const new({required this.reply, this.params = const <String, String>{}});

  final ScriptedReply reply;
  final Map<String, String> params;
}

/// A text bubble followed by tappable option chips (failed time parse).
class ChipsAction extends AgentAction {
  const new({
    required this.reply,
    required this.options,
    this.params = const <String, String>{},
  });

  final ScriptedReply reply;
  final Map<String, String> params;

  /// Values sent back as guest messages when tapped; must stay parseable.
  final List<String> options;
}

/// An order card appended to the transcript (status [OrderStatus.pending]).
class CreateOrderAction extends AgentAction {
  const new({
    required this.kind,
    required this.quantity,
    this.amenity,
    this.slotTime,
    this.nextDay = false,
  });

  final OrderKind kind;
  final Amenity? amenity;
  final int quantity;
  final String? slotTime;
  final bool nextDay;
}

/// Agent output: ordered actions plus the next slot-filling state.
class AgentResponse {
  const new({required this.actions, this.nextPending});

  final List<AgentAction> actions;

  /// Flow to keep active after this turn; null closes any flow.
  final PendingSlot? nextPending;
}

/// Scripted concierge contract (PRD 7.4).
abstract class ConciergeAgent {
  AgentResponse respond(AgentRequest request);
}

/// Intent keyword table (PRD 7.1: trigger words live in the data layer;
/// only display copy is localized). Matched top to bottom on normalized
/// substring containment.
const _intentKeywords = <Intent, List<String>>{
  Intent.slippers: ['拖鞋', 'slipper'],
  Intent.toiletries: [
    '洗漱',
    '牙刷',
    '牙膏',
    '剃须',
    'toiletries',
    'toothbrush',
    'toothpaste',
    'razor',
  ],
  Intent.towels: ['毛巾', '浴巾', 'towel'],
  Intent.water: ['矿泉水', '饮用水', '水', 'water'],
  Intent.wifi: ['wifi', 'wi-fi', '密码', '无线网', 'wireless', 'password'],
  Intent.breakfast: ['早餐', '早饭', 'breakfast'],
  Intent.wakeup: ['叫醒', '叫我起床', 'wake-up', 'wakeup', 'wake up'],
  Intent.lateCheckout: [
    '延迟退房',
    '退房',
    'late check-out',
    'late checkout',
    'checkout',
  ],
};

/// Intents the scripted engine recognizes (PRD 7.1). Fallback is implicit.
enum Intent {
  slippers,
  toiletries,
  towels,
  water,
  wifi,
  breakfast,
  wakeup,
  lateCheckout,
}

/// Keyword-table mock agent: intent match -> slot追问 -> order card.
class ScriptedConciergeAgent implements ConciergeAgent {
  const new();

  @override
  AgentResponse respond(AgentRequest request) {
    final normalized = normalizeInput(request.input);
    final pending = request.pending;
    if (pending != null) {
      return _continueFlow(normalized, pending);
    }
    return _matchIntent(normalized);
  }

  AgentResponse _continueFlow(String text, PendingSlot pending) {
    if (isCancelIntent(text)) {
      return const AgentResponse(
        actions: [SayAction(reply: ScriptedReply.cancelAck)],
      );
    }
    final kind = pending.kind;
    if (kind == OrderKind.amenity) {
      return _continueQuantityFlow(text, pending);
    }
    return _continueTimeFlow(text, pending);
  }

  AgentResponse _continueQuantityFlow(String text, PendingSlot pending) {
    final quantity = parseQuantity(text);
    if (quantity == null) {
      return AgentResponse(
        actions: [const SayAction(reply: ScriptedReply.quantityInvalid)],
        nextPending: pending,
      );
    }
    return AgentResponse(
      actions: [
        CreateOrderAction(
          kind: OrderKind.amenity,
          amenity: pending.amenity,
          quantity: quantity,
        ),
      ],
    );
  }

  AgentResponse _continueTimeFlow(String text, PendingSlot pending) {
    final slot = parseTimeOfDay(text);
    if (slot == null) {
      return AgentResponse(
        actions: [
          ChipsAction(
            reply: ScriptedReply.timeChipsPrompt,
            options: _defaultSlots(pending.kind),
          ),
        ],
        nextPending: pending,
      );
    }
    return AgentResponse(
      actions: [
        CreateOrderAction(
          kind: pending.kind,
          quantity: 1,
          slotTime: slot.label,
          nextDay: pending.kind == OrderKind.wakeup || slot.nextDay,
        ),
      ],
    );
  }

  AgentResponse _matchIntent(String text) {
    switch (_detectIntent(text)) {
      case Intent.slippers:
        return _askQuantity(Amenity.slippers);
      case Intent.toiletries:
        return _askQuantity(Amenity.toiletries);
      case Intent.towels:
        return _askQuantity(Amenity.towels);
      case Intent.water:
        return _askQuantity(Amenity.water);
      case Intent.wifi:
        return const AgentResponse(
          actions: [
            SayAction(
              reply: ScriptedReply.wifiAnswer,
              params: <String, String>{
                'ssid': DemoAccess.wifiSsid,
                'password': DemoAccess.wifiPassword,
              },
            ),
          ],
        );
      case Intent.breakfast:
        return const AgentResponse(
          actions: [SayAction(reply: ScriptedReply.breakfastAnswer)],
        );
      case Intent.wakeup:
        return _startReservation(text, OrderKind.wakeup);
      case Intent.lateCheckout:
        return _startReservation(text, OrderKind.lateCheckout);
      case null:
        return const AgentResponse(
          actions: [SayAction(reply: ScriptedReply.fallback)],
        );
    }
  }

  /// Returns the first intent whose keyword list matches, scanning the
  /// declaration order above; null means fallback (PRD 7.1).
  Intent? _detectIntent(String text) {
    for (final entry in _intentKeywords.entries) {
      if (entry.value.any(text.contains)) {
        return entry.key;
      }
    }
    return null;
  }

  AgentResponse _askQuantity(Amenity amenity) {
    return AgentResponse(
      actions: [
        SayAction(
          reply: ScriptedReply.askQuantity,
          params: <String, String>{'amenity': amenity.name},
        ),
      ],
      nextPending: PendingSlot(kind: OrderKind.amenity, amenity: amenity),
    );
  }

  /// Reservations read the time straight from the first message (S4);
  /// without one the agent asks and keeps the flow open.
  AgentResponse _startReservation(String text, OrderKind kind) {
    final slot = parseTimeOfDay(text);
    if (slot != null) {
      return AgentResponse(
        actions: [
          CreateOrderAction(
            kind: kind,
            quantity: 1,
            slotTime: slot.label,
            nextDay: kind == OrderKind.wakeup || slot.nextDay,
          ),
        ],
      );
    }
    final reply = kind == OrderKind.wakeup
        ? ScriptedReply.askWakeupTime
        : ScriptedReply.askLateCheckoutTime;
    return AgentResponse(
      actions: [SayAction(reply: reply)],
      nextPending: PendingSlot(kind: kind),
    );
  }

  /// Default chip options when a time cannot be parsed (PRD 7.1): the
  /// wake-up default 明早 07:00 and one alternative; late check-out from
  /// its 14:00 default.
  List<String> _defaultSlots(OrderKind kind) {
    return kind == OrderKind.wakeup ? ['07:00', '08:00'] : ['14:00', '15:00'];
  }
}
