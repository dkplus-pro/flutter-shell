import 'dart:async';
import 'dart:convert';

import 'package:app_core/app_core.dart';
import 'package:fluttershell/core/logging/log_providers.dart';
import 'package:fluttershell/core/storage/storage_providers.dart';
import 'package:fluttershell/features/hotel/application/hotel_clock.dart';
import 'package:fluttershell/features/hotel/application/hotel_clock_provider.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/features/hotel/data/concierge_agent.dart';
import 'package:fluttershell/features/hotel/data/guest_profile.dart';
import 'package:fluttershell/features/hotel/data/hotel_order.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hotel_chat_providers.g.dart';

const _messagesKey = 'hotel.chat.messages.v1';
const _ordersKey = 'hotel.orders.v1';

/// Mock guest binding (D8): fixed demo room for the whole session. Not
/// persisted; guest display name is ARB copy resolved at presentation time.
@riverpod
GuestProfile hotelGuestProfile(Ref ref) {
  return const GuestProfile(roomNo: '1208');
}

/// Immutable chat session state: transcript, orders and the pending
/// slot-filling flow. Transient UI state (input text, quick panel) stays in
/// the page widget.
class HotelChatState {
  const new({
    required this.messages,
    required this.orders,
    this.typing = false,
    this.pending,
  });

  final List<ChatMessage> messages;

  /// Orders by id, referenced from order-card messages.
  final Map<String, HotelOrder> orders;

  /// True while the "typing" indicator occupies the stream (PRD 6.2: never
  /// persisted).
  final bool typing;

  /// Active slot-filling flow; not persisted (PRD 8 restores messages and
  /// orders only, an interrupted flow restarts).
  final PendingSlot? pending;

  HotelChatState withMessage(ChatMessage message) {
    return HotelChatState(
      messages: [...messages, message],
      orders: orders,
      typing: typing,
      pending: pending,
    );
  }

  HotelChatState withPending(PendingSlot? pending) {
    return HotelChatState(
      messages: messages,
      orders: orders,
      typing: typing,
      pending: pending,
    );
  }

  HotelChatState withTyping({required bool typing}) {
    return HotelChatState(
      messages: messages,
      orders: orders,
      typing: typing,
      pending: pending,
    );
  }

  HotelChatState withOrder(HotelOrder order) {
    return HotelChatState(
      messages: messages,
      orders: {...orders, order.id: order},
      typing: typing,
      pending: pending,
    );
  }
}

/// Chat session controller: transcript, concierge reply queue, order state
/// machine and KeyValueStore persistence.
///
/// keepAlive: the transcript, the reply queue and the order timers must
/// survive tab switches and pushes; persistence is written from here so the
/// session also survives restarts (PRD D10).
@Riverpod(keepAlive: true)
class HotelChatController extends _$HotelChatController {
  final List<Timer> _timers = <Timer>[];
  final List<AgentResponse> _queue = <AgentResponse>[];
  bool _draining = false;
  int _seq = 0;
  late String _room;

  KeyValueStore get _store => ref.read(keyValueStoreProvider);
  HotelClock get _clock => ref.read(hotelClockProvider);
  AppLogger get _log => ref.read(appLoggerProvider).child('hotel');

  ConciergeAgent get _agent => const ScriptedConciergeAgent();

  @override
  Future<HotelChatState> build() async {
    ref.onDispose(_disposeTimers);
    _room = ref.watch(hotelGuestProfileProvider).roomNo;
    final loaded = await _restore();
    // Welcome plays only when there is no recoverable history (PRD 6.2).
    final state = loaded == null || loaded.messages.isEmpty
        ? _seedWelcome()
        : loaded;
    unawaited(_persist(state));
    return state;
  }

  HotelChatState _seedWelcome() {
    return HotelChatState(
      messages: [
        ChatMessage(
          id: _nextId('welcome'),
          role: MessageRole.concierge,
          kind: MessageKind.text,
          reply: ScriptedReply.welcome,
          params: <String, String>{'room': _room},
          createdAt: _clock.now(),
        ),
      ],
      orders: const <String, HotelOrder>{},
    );
  }

  /// Restores transcript + orders (PRD D10). Orders caught mid-flight
  /// (placed/delivering) fall straight to the delivered terminal state —
  /// the documented recovery strategy (PRD 11: take the simple one).
  Future<HotelChatState?> _restore() async {
    final messagesJson = await _store.read(_messagesKey);
    if (messagesJson == null) {
      return null;
    }
    final messages = (jsonDecode(messagesJson) as List<Object?>)
        .map((entry) => ChatMessage.fromJson(entry! as Map<String, Object?>))
        .toList();

    final orders = <String, HotelOrder>{};
    final ordersJson = await _store.read(_ordersKey);
    if (ordersJson != null) {
      for (final entry in jsonDecode(ordersJson) as List<Object?>) {
        final order = HotelOrder.fromJson(entry! as Map<String, Object?>);
        orders[order.id] = _settleInFlight(order);
      }
    }
    return HotelChatState(messages: messages, orders: orders);
  }

  HotelOrder _settleInFlight(HotelOrder order) {
    if (order.status == OrderStatus.placed ||
        order.status == OrderStatus.delivering) {
      return order.copyWith(
        status: OrderStatus.delivered,
        updatedAt: _clock.now(),
      );
    }
    return order;
  }

  /// Appends a guest text message and runs the scripted agent turn.
  void sendGuestText(String raw) {
    final current = state.value;
    if (current == null) {
      return;
    }
    final text = raw.trim();
    if (text.isEmpty) {
      return;
    }
    final message = ChatMessage(
      id: _nextId('m'),
      role: MessageRole.guest,
      kind: MessageKind.text,
      text: text,
      createdAt: _clock.now(),
    );
    final response = _agent.respond(
      AgentRequest(input: text, pending: current.pending, roomNo: _room),
    );
    _update(current.withMessage(message).withPending(response.nextPending));
    _enqueue(response);
  }

  /// Confirms a pending order card. Only the first confirmation counts
  /// (PRD 6.3); amenity orders then start the mock delivery timeline.
  void confirmOrder(String orderId, {int? quantity}) {
    final current = state.value;
    if (current == null) {
      return;
    }
    final order = current.orders[orderId];
    if (order == null || order.isConfirmed) {
      return;
    }
    final confirmed = order.copyWith(
      status: order.kind == OrderKind.amenity
          ? OrderStatus.placed
          : OrderStatus.reserved,
      quantity: quantity ?? order.quantity,
      updatedAt: _clock.now(),
    );
    _update(current.withOrder(confirmed));
    if (confirmed.status == OrderStatus.placed) {
      _scheduleTransition(
        orderId,
        from: OrderStatus.placed,
        to: OrderStatus.delivering,
        delay: _clock.placedToDelivering,
      );
      _scheduleTransition(
        orderId,
        from: OrderStatus.delivering,
        to: OrderStatus.delivered,
        delay: _clock.placedToDelivering + _clock.deliveringToDelivered,
      );
    }
  }

  /// Submits the star rating of a delivered order; only once (PRD 6.3).
  void rateOrder(String orderId, int stars) {
    final current = state.value;
    if (current == null || stars < 1 || stars > 5) {
      return;
    }
    final order = current.orders[orderId];
    if (order == null ||
        order.status != OrderStatus.delivered ||
        order.rating != null) {
      return;
    }
    _update(
      current.withOrder(
        order.copyWith(
          status: OrderStatus.rated,
          rating: stars,
          updatedAt: _clock.now(),
        ),
      ),
    );
  }

  void _scheduleTransition(
    String orderId, {
    required OrderStatus from,
    required OrderStatus to,
    required Duration delay,
  }) {
    _timers.add(_clock.schedule(delay, () => _transition(orderId, from, to)));
  }

  void _transition(String orderId, OrderStatus from, OrderStatus to) {
    final current = state.value;
    if (current == null) {
      return;
    }
    final order = current.orders[orderId];
    if (order == null || order.status != from) {
      return;
    }
    _update(
      current.withOrder(order.copyWith(status: to, updatedAt: _clock.now())),
    );
  }

  // -- Reply pacing (PRD 7.3): typing indicator, one reply in flight -----

  void _enqueue(AgentResponse response) {
    _queue.add(response);
    if (!_draining) {
      _drainNext();
    }
  }

  void _drainNext() {
    final current = state.value;
    if (current == null || _queue.isEmpty) {
      _draining = false;
      return;
    }
    _draining = true;
    final response = _queue.removeAt(0);
    _update(current.withTyping(typing: true));
    _timers.add(
      _clock.schedule(_clock.nextTypingDelay(), () {
        _applyResponse(response);
        _drainNext();
      }),
    );
  }

  void _applyResponse(AgentResponse response) {
    final current = state.value;
    if (current == null) {
      return;
    }
    var next = current.withTyping(typing: false);
    for (final action in response.actions) {
      switch (action) {
        case SayAction(:final reply, :final params):
          next = next.withMessage(
            ChatMessage(
              id: _nextId('r'),
              role: MessageRole.concierge,
              kind: MessageKind.text,
              reply: reply,
              params: params,
              createdAt: _clock.now(),
            ),
          );
        case ChipsAction(:final reply, :final params, :final options):
          next = next.withMessage(
            ChatMessage(
              id: _nextId('r'),
              role: MessageRole.concierge,
              kind: MessageKind.chips,
              reply: reply,
              params: params,
              chips: options,
              createdAt: _clock.now(),
            ),
          );
        case CreateOrderAction():
          final order = HotelOrder(
            id: _nextId('o'),
            kind: action.kind,
            amenity: action.amenity,
            quantity: action.quantity,
            slotTime: action.slotTime,
            nextDay: action.nextDay,
            status: OrderStatus.pending,
            createdAt: _clock.now(),
            updatedAt: _clock.now(),
          );
          next = next
              .withOrder(order)
              .withMessage(
                ChatMessage(
                  id: _nextId('m'),
                  role: MessageRole.concierge,
                  kind: MessageKind.order,
                  orderId: order.id,
                  createdAt: _clock.now(),
                ),
              );
      }
    }
    _update(next);
  }

  // -- Infrastructure ----------------------------------------------------

  void _update(HotelChatState next) {
    state = AsyncData(next);
    unawaited(_persist(next));
  }

  Future<void> _persist(HotelChatState value) async {
    try {
      await _store.write(
        _messagesKey,
        jsonEncode(value.messages.map((m) => m.toJson()).toList()),
      );
      // The provider may have been invalidated across the async gap.
      if (!ref.mounted) {
        return;
      }
      await _store.write(
        _ordersKey,
        jsonEncode(value.orders.values.map((o) => o.toJson()).toList()),
      );
    } on Exception catch (error, stackTrace) {
      if (!ref.mounted) {
        return;
      }
      _log.warning(
        'failed to persist hotel chat session',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String _nextId(String prefix) {
    _seq += 1;
    return '${prefix}_${_clock.now().millisecondsSinceEpoch}_$_seq';
  }

  void _disposeTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }
}
