import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/features/hotel/data/hotel_order.dart';

import 'chat_harness.dart';

void main() {
  test(
    'welcome message is seeded once on a fresh store and persisted',
    () async {
      final harness = Harness();
      await harness.ready();

      final state = harness.state;
      expect(state.messages, hasLength(1));
      expect(state.messages.single.role, MessageRole.concierge);
      expect(state.messages.single.reply, ScriptedReply.welcome);
      expect(state.messages.single.params['room'], '1208');
      expect(
        harness.store.values.values.any(
          (payload) => payload.contains('welcome'),
        ),
        isTrue,
        reason: 'the welcome message is persisted as it is seeded',
      );

      // A restart must not duplicate the welcome message.
      final restarted = Harness.withStore(harness.store);
      await restarted.ready();
      expect(restarted.state.messages, hasLength(1));

      harness.dispose();
      restarted.dispose();
    },
  );

  test(
    'chat transcript and orders round-trip through the KeyValueStore',
    () async {
      final harness = Harness();
      await harness.ready();

      harness.notifier.sendGuestText('我需要送几双一次性拖鞋到房间。');
      harness.schedule.elapse(const Duration(seconds: 2));
      harness.notifier.sendGuestText('2 双');
      harness.schedule.elapse(const Duration(seconds: 2));
      final orderId = harness.state.orders.keys.single;
      harness.notifier.confirmOrder(orderId, quantity: 2);
      harness.schedule.elapse(const Duration(seconds: 3));
      final beforeRestart = harness.state;
      expect(beforeRestart.orders[orderId]!.status, OrderStatus.delivering);

      // Same store, fresh container: the session is restored.
      final restarted = Harness.withStore(harness.store);
      await restarted.ready();
      final restored = restarted.state;

      expect(restored.messages.length, beforeRestart.messages.length);
      expect(restored.messages.first.reply, ScriptedReply.welcome);
      expect(restored.orders[orderId], isNotNull);
      expect(
        restored.orders[orderId]!.status,
        OrderStatus.delivered,
        reason:
            'orders caught mid-flight settle to the delivered terminal '
            'state on restore (documented strategy)',
      );
      expect(restored.typing, isFalse, reason: 'typing is never persisted');
      expect(restored.pending, isNull);
      expect(restored.orders[orderId]!.quantity, 2);

      // The restored terminal state stays final and rateable exactly once.
      restarted.notifier.rateOrder(orderId, 4);
      restarted.notifier.rateOrder(orderId, 2);
      await restarted.settle();
      expect(restarted.state.orders[orderId]!.rating, 4);

      harness.dispose();
      restarted.dispose();
    },
  );

  test('unconfirmed pending cards stay editable after restore', () async {
    final harness = Harness();
    await harness.ready();

    harness.notifier.sendGuestText('明早 7 点叫我起床');
    harness.schedule.elapse(const Duration(seconds: 2));
    final orderId = harness.state.orders.keys.single;

    final restarted = Harness.withStore(harness.store);
    await restarted.ready();
    expect(restarted.state.orders[orderId]!.status, OrderStatus.pending);

    restarted.notifier.confirmOrder(orderId);
    await restarted.settle();
    expect(restarted.state.orders[orderId]!.status, OrderStatus.reserved);

    harness.dispose();
    restarted.dispose();
  });
}
