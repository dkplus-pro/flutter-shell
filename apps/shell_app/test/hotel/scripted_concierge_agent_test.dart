import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/features/hotel/data/amenity_catalog.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/features/hotel/data/concierge_agent.dart';
import 'package:fluttershell/features/hotel/data/hotel_order.dart';

void main() {
  const agent = ScriptedConciergeAgent();

  AgentResponse respond(
    String input, {
    PendingSlot? pending,
    Set<OrderKind> activeReservations = const <OrderKind>{},
  }) {
    return agent.respond(
      AgentRequest(
        input: input,
        pending: pending,
        roomNo: '1208',
        activeReservationKinds: activeReservations,
      ),
    );
  }

  SayAction sayOf(AgentResponse response) =>
      response.actions.whereType<SayAction>().single;

  group('intent detection hits every scripted intent (PRD 7.1)', () {
    test('slippers zh keyword opens the quantity flow', () {
      final response = respond('我需要送几双一次性拖鞋到房间。');
      expect(sayOf(response).reply, ScriptedReply.askQuantity);
      expect(response.nextPending, isNotNull);
      expect(response.nextPending!.amenity, Amenity.slippers);
    });

    test('slippers en keyword works on the en preset', () {
      final response = respond('I need some disposable slippers, please.');
      expect(sayOf(response).reply, ScriptedReply.askQuantity);
      expect(response.nextPending!.amenity, Amenity.slippers);
    });

    test('toiletries keywords (zh and en variants)', () {
      expect(respond('请给我送一套洗漱用品。').nextPending!.amenity, Amenity.toiletries);
      expect(
        respond('bring a toothbrush please').nextPending!.amenity,
        Amenity.toiletries,
      );
    });

    test('towels keywords', () {
      expect(respond('请给我送几条浴巾').nextPending!.amenity, Amenity.towels);
      expect(
        respond('fresh towels please').nextPending!.amenity,
        Amenity.towels,
      );
    });

    test('water keywords', () {
      expect(respond('请给我送几瓶矿泉水').nextPending!.amenity, Amenity.water);
      expect(respond('some water please').nextPending!.amenity, Amenity.water);
    });

    test('wifi question answers directly with demo credentials', () {
      final response = respond('WiFi 密码是多少？');
      final say = sayOf(response);
      expect(say.reply, ScriptedReply.wifiAnswer);
      expect(say.params['ssid'], 'Hotel-Guest');
      expect(say.params['password'], '12345678');
      expect(response.nextPending, isNull);
    });

    test('breakfast question answers directly', () {
      expect(respond('早餐时间是几点？').actions.single, isA<SayAction>());
      expect(
        sayOf(respond('breakfast time?')).reply,
        ScriptedReply.breakfastAnswer,
      );
    });

    test('wakeup without a time asks for the time slot', () {
      final response = respond('我想设置叫醒服务。');
      expect(sayOf(response).reply, ScriptedReply.askWakeupTime);
      expect(response.nextPending!.kind, OrderKind.wakeup);
    });

    test('wakeup with an inline time creates the reservation card (S4)', () {
      final response = respond('明早 7 点叫我起床');
      final action = response.actions.whereType<CreateOrderAction>().single;
      expect(action.kind, OrderKind.wakeup);
      expect(action.slotTime, '07:00');
      expect(action.nextDay, isTrue);
      expect(response.nextPending, isNull);
    });

    test('late checkout without a time asks for the time slot', () {
      final response = respond('我想申请延迟退房。');
      expect(sayOf(response).reply, ScriptedReply.askLateCheckoutTime);
      expect(response.nextPending!.kind, OrderKind.lateCheckout);
    });

    test('fallback for unmatched input (S5)', () {
      expect(sayOf(respond('今天天气如何')).reply, ScriptedReply.fallback);
      expect(
        sayOf(respond('what is the weather like')).reply,
        ScriptedReply.fallback,
      );
    });
  });

  group('normalization', () {
    test('full-width characters and case fold to half-width lowercase', () {
      final response = respond('ＷＩＦＩ 密码');
      expect(sayOf(response).reply, ScriptedReply.wifiAnswer);
    });

    test('uppercase english matches', () {
      expect(sayOf(respond('TOWELS PLEASE')).reply, ScriptedReply.askQuantity);
    });
  });

  group('quantity slot (PRD 7.1)', () {
    late PendingSlot pending;

    setUp(() {
      pending = respond('我需要拖鞋').nextPending!;
    });

    test('arabic digits converge, unit text is ignored', () {
      final response = respond('2 双', pending: pending);
      expect(
        response.actions.whereType<CreateOrderAction>().single.quantity,
        2,
      );
      expect(response.nextPending, isNull);
    });

    test('chinese numeral 两 maps to 2', () {
      final response = respond('两双', pending: pending);
      expect(
        response.actions.whereType<CreateOrderAction>().single.quantity,
        2,
      );
    });

    test('二 also maps to 2, 一..九 map to 1..9', () {
      int? quantityOf(String input) => respond(
        input,
        pending: pending,
      ).actions.whereType<CreateOrderAction>().single.quantity;

      expect(quantityOf('二双'), 2);
      expect(quantityOf('一双'), 1);
      expect(quantityOf('九双'), 9);
    });

    test('out of range or missing quantity re-asks', () {
      expect(respond('12双', pending: pending).actions.single, isA<SayAction>());
      expect(
        sayOf(respond('12双', pending: pending)).reply,
        ScriptedReply.quantityInvalid,
      );
      expect(
        sayOf(respond('随便', pending: pending)).reply,
        ScriptedReply.quantityInvalid,
      );
      expect(respond('随便', pending: pending).nextPending, pending);
    });

    test('cancel phrase exits the flow', () {
      final response = respond('不用了', pending: pending);
      expect(sayOf(response).reply, ScriptedReply.cancelAck);
      expect(response.nextPending, isNull);
    });
  });

  group('time slot (PRD 7.1)', () {
    late PendingSlot wakeupPending;

    setUp(() {
      wakeupPending = respond('我想设置叫醒服务。').nextPending!;
    });

    test('HH:mm template parses', () {
      final response = respond('07:00', pending: wakeupPending);
      final action = response.actions.whereType<CreateOrderAction>().single;
      expect(action.slotTime, '07:00');
      expect(action.nextDay, isTrue);
    });

    test('明天早上7点 parses to 07:00 tomorrow', () {
      final response = respond('明天早上7点', pending: wakeupPending);
      expect(
        response.actions.whereType<CreateOrderAction>().single.slotTime,
        '07:00',
      );
    });

    test('下午两点 parses to 14:00', () {
      final response = respond('下午两点', pending: wakeupPending);
      expect(
        response.actions.whereType<CreateOrderAction>().single.slotTime,
        '14:00',
      );
    });

    test('晚上八点半 parses to 20:30', () {
      final response = respond('晚上八点半', pending: wakeupPending);
      expect(
        response.actions.whereType<CreateOrderAction>().single.slotTime,
        '20:30',
      );
    });

    test('unparseable time offers two default chips and keeps the flow', () {
      final response = respond('早上晚点吧', pending: wakeupPending);
      final chips = response.actions.whereType<ChipsAction>().single;
      expect(chips.reply, ScriptedReply.timeChipsPrompt);
      expect(chips.options, hasLength(2));
      expect(
        respond('早上晚点吧', pending: wakeupPending).nextPending,
        wakeupPending,
      );
    });

    test('cancel phrase exits the time flow', () {
      final response = respond('算了', pending: wakeupPending);
      expect(sayOf(response).reply, ScriptedReply.cancelAck);
      expect(response.nextPending, isNull);
    });
  });

  group('open flow is abandoned by a different quick-service intent', () {
    test('time flow -> another quick item answers that item instead', () {
      final pending = respond('我想申请延迟退房。').nextPending!;
      final response = respond('WiFi 密码是多少？', pending: pending);

      expect(sayOf(response).reply, ScriptedReply.wifiAnswer);
      expect(response.nextPending, isNull);
      expect(response.actions.whereType<CreateOrderAction>(), isEmpty);
    });

    test('quantity flow -> another amenity asks for the new item', () {
      final pending = respond('我需要拖鞋').nextPending!;
      final response = respond('请给我送几条干净毛巾。', pending: pending);

      final say = sayOf(response);
      expect(say.reply, ScriptedReply.askQuantity);
      expect(say.params['amenity'], Amenity.towels.name);
      expect(response.nextPending!.amenity, Amenity.towels);
    });

    test('time flow -> reservation for another time still parses', () {
      final pending = respond('我想设置叫醒服务。').nextPending!;
      final response = respond('明天早上7点', pending: pending);

      final action = response.actions.whereType<CreateOrderAction>().single;
      expect(action.kind, OrderKind.wakeup);
      expect(action.slotTime, '07:00');
      expect(response.nextPending, isNull);
    });
  });

  group('one reservation per kind', () {
    test('second wake-up request is refused', () {
      final response = respond(
        '明早 7 点叫我起床',
        activeReservations: const {OrderKind.wakeup},
      );

      expect(sayOf(response).reply, ScriptedReply.wakeupAlreadyBooked);
      expect(response.actions.whereType<CreateOrderAction>(), isEmpty);
      expect(response.nextPending, isNull);
    });

    test('second late checkout request is refused', () {
      final response = respond(
        '我想明天 14:00 退房。',
        activeReservations: const {OrderKind.lateCheckout},
      );

      expect(sayOf(response).reply, ScriptedReply.lateCheckoutAlreadyRequested);
      expect(response.actions.whereType<CreateOrderAction>(), isEmpty);
    });

    test('a different reservation kind is still allowed', () {
      final response = respond(
        '我想明天 14:00 退房。',
        activeReservations: const {OrderKind.wakeup},
      );

      expect(
        response.actions.whereType<CreateOrderAction>().single.kind,
        OrderKind.lateCheckout,
      );
    });
  });
}
