import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/features/hotel/data/hotel_order.dart';

import 'chat_harness.dart';

void main() {
  test(
    'order state machine: full flow, intervals, single confirm, single rating',
    () async {
      final harness = Harness();
      await harness.ready();

      harness.notifier.sendGuestText('我需要送几双一次性拖鞋到房间。');
      await harness.settle();
      // Typing indicator occupies the stream until the delay elapses.
      expect(harness.state.typing, isTrue);
      harness.schedule.elapse(const Duration(seconds: 2));
      expect(harness.state.typing, isFalse);
      expect(harness.state.messages.last.reply, ScriptedReply.askQuantity);

      harness.notifier.sendGuestText('2 双');
      harness.schedule.elapse(const Duration(seconds: 2));
      final order = harness.state.orders.values.single;
      expect(order.status, OrderStatus.pending);
      expect(order.quantity, 2);

      // Only the first confirmation counts; later calls are no-ops.
      harness.notifier.confirmOrder(order.id, quantity: 2);
      harness.notifier.confirmOrder(order.id, quantity: 7);
      await harness.settle();
      expect(harness.state.orders[order.id]!.status, OrderStatus.placed);
      expect(harness.state.orders[order.id]!.quantity, 2);

      harness.schedule.elapse(const Duration(seconds: 2));
      expect(
        harness.state.orders[order.id]!.status,
        OrderStatus.placed,
        reason: 'placed -> delivering takes ~3s',
      );
      harness.schedule.elapse(const Duration(seconds: 1));
      expect(harness.state.orders[order.id]!.status, OrderStatus.delivering);
      harness.schedule.elapse(const Duration(seconds: 7));
      expect(
        harness.state.orders[order.id]!.status,
        OrderStatus.delivering,
        reason: 'delivering -> delivered takes ~8s after delivering',
      );
      harness.schedule.elapse(const Duration(seconds: 1));
      expect(harness.state.orders[order.id]!.status, OrderStatus.delivered);

      // Only the first rating counts.
      harness.notifier.rateOrder(order.id, 5);
      harness.notifier.rateOrder(order.id, 3);
      await harness.settle();
      expect(harness.state.orders[order.id]!.status, OrderStatus.rated);
      expect(harness.state.orders[order.id]!.rating, 5);

      harness.dispose();
    },
  );

  test(
    'reservation card confirms straight into the reserved terminal state',
    () async {
      final harness = Harness();
      await harness.ready();

      harness.notifier.sendGuestText('明早 7 点叫我起床');
      harness.schedule.elapse(const Duration(seconds: 2));
      final order = harness.state.orders.values.single;
      expect(order.kind, OrderKind.wakeup);
      expect(order.slotTime, '07:00');
      expect(order.nextDay, isTrue);

      harness.notifier.confirmOrder(order.id);
      await harness.settle();
      expect(harness.state.orders[order.id]!.status, OrderStatus.reserved);
      harness.schedule.elapse(const Duration(seconds: 12));
      expect(
        harness.state.orders[order.id]!.status,
        OrderStatus.reserved,
        reason: 'reservations have no delivery flow',
      );

      harness.dispose();
    },
  );

  test(
    'concierge replies are serialized: one reply in flight at a time',
    () async {
      final harness = Harness();
      await harness.ready();

      // Two guest turns before any reply was applied: both responses queue.
      harness.notifier.sendGuestText('我需要拖鞋');
      harness.notifier.sendGuestText('我需要毛巾');
      await harness.settle();

      harness.schedule.elapse(const Duration(milliseconds: 400));
      expect(harness.state.typing, isTrue);
      expect(
        harness.state.messages
            .where((m) => m.role == MessageRole.concierge)
            .length,
        1,
        reason: 'nothing applied yet except the welcome message',
      );

      // One elapse drains exactly one queued reply; the next one stays in
      // flight (typing still on).
      harness.schedule.elapse(const Duration(seconds: 5));
      expect(harness.state.typing, isTrue);
      expect(
        harness.state.messages
            .where((m) => m.role == MessageRole.concierge)
            .last
            .reply,
        ScriptedReply.askQuantity,
      );

      harness.schedule.elapse(const Duration(seconds: 5));
      expect(harness.state.typing, isFalse, reason: 'queue fully drained');
      final replies = harness.state.messages
          .where((m) => m.role == MessageRole.concierge)
          .toList();
      expect(replies, hasLength(3));
      expect(replies[1].reply, ScriptedReply.askQuantity);
      expect(replies[2].reply, ScriptedReply.quantityInvalid);

      await harness.settle();
      harness.dispose();
    },
  );
}
