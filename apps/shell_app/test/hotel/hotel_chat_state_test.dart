import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/features/hotel/application/hotel_chat_providers.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/features/hotel/data/concierge_agent.dart';
import 'package:fluttershell/features/hotel/data/hotel_order.dart';

ChatMessage _message({
  required String id,
  required MessageKind kind,
  MessageRole role = MessageRole.concierge,
}) {
  return ChatMessage(
    id: id,
    role: role,
    kind: kind,
    createdAt: DateTime(2026, 11, 2),
  );
}

void main() {
  const pending = PendingSlot(kind: OrderKind.lateCheckout);
  const pendingWakeup = PendingSlot(kind: OrderKind.wakeup);

  test('the latest chips prompt of an open flow stays active', () {
    final state = HotelChatState(
      messages: [_message(id: 'chips_1', kind: MessageKind.chips)],
      orders: const {},
      pending: pending,
    );

    expect(state.activeChipsMessageId, 'chips_1');
  });

  test('a resolved flow disables chips history', () {
    final state = HotelChatState(
      messages: [_message(id: 'chips_1', kind: MessageKind.chips)],
      orders: const {},
    );

    expect(state.activeChipsMessageId, isNull);
  });

  test('a superseded chips prompt is not active after a newer message', () {
    final state = HotelChatState(
      messages: [
        _message(id: 'chips_1', kind: MessageKind.chips),
        _message(
          id: 'guest_1',
          kind: MessageKind.text,
          role: MessageRole.guest,
        ),
      ],
      orders: const {},
      pending: pendingWakeup,
    );

    expect(state.activeChipsMessageId, isNull);
  });
}
