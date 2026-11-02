import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/features/hotel/presentation/order_sheet.dart';

const _items = [
  HotelOrderSheetItem(
    id: 'o1',
    title: 'Extra towels',
    subtitle: 'Room 1208',
    statusLabel: 'Delivering',
    status: HotelOrderSheetStatus.delivering,
    timeText: '12:03',
  ),
  HotelOrderSheetItem(
    id: 'o2',
    title: 'Late checkout',
    subtitle: 'Nov 2, 14:00',
    statusLabel: 'Reserved',
    status: HotelOrderSheetStatus.reserved,
    timeText: '09:40',
  ),
  HotelOrderSheetItem(
    id: 'o3',
    title: 'Club sandwich',
    subtitle: 'In-room dining',
    statusLabel: 'Delivered',
    status: HotelOrderSheetStatus.delivered,
    timeText: '08:15',
  ),
];

Future<void> _openSheet(
  WidgetTester tester, {
  required List<HotelOrderSheetItem> items,
  required String emptyText,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () {
                unawaited(
                  showHotelOrderSheet(
                    context,
                    items: items,
                    title: 'My orders',
                    emptyText: emptyText,
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders every row with subtitle, pill and time', (tester) async {
    await _openSheet(tester, items: _items, emptyText: 'Nothing here');

    expect(find.text('My orders'), findsOneWidget);
    for (final item in _items) {
      expect(find.text(item.title), findsOneWidget);
      expect(find.text(item.subtitle), findsOneWidget);
      expect(find.text(item.statusLabel), findsOneWidget);
      expect(find.text(item.timeText), findsOneWidget);
    }
  });

  testWidgets('pill label uses the status accent color', (tester) async {
    await _openSheet(tester, items: _items, emptyText: 'Nothing here');

    expect(
      tester.widget<Text>(find.text('Delivering')).style?.color,
      hotelOrderSheetStatusColor(HotelOrderSheetStatus.delivering),
    );
    expect(
      tester.widget<Text>(find.text('Reserved')).style?.color,
      hotelOrderSheetStatusColor(HotelOrderSheetStatus.reserved),
    );
    expect(
      tester.widget<Text>(find.text('Delivered')).style?.color,
      hotelOrderSheetStatusColor(HotelOrderSheetStatus.delivered),
    );
  });

  testWidgets('pill background is a translucent status accent', (tester) async {
    await _openSheet(tester, items: _items, emptyText: 'Nothing here');

    final expected = hotelOrderSheetStatusColor(
      HotelOrderSheetStatus.delivering,
    ).withValues(alpha: 0.12);
    final pillFound = tester
        .widgetList<Container>(
          find.ancestor(
            of: find.text('Delivering'),
            matching: find.byType(Container),
          ),
        )
        .any(
          (container) =>
              container.decoration is BoxDecoration &&
              (container.decoration! as BoxDecoration).color == expected,
        );
    expect(pillFound, isTrue);
  });

  testWidgets('shows the empty state with the injected empty text', (
    tester,
  ) async {
    await _openSheet(tester, items: const [], emptyText: 'No orders yet');

    expect(find.text('My orders'), findsOneWidget);
    expect(find.text('No orders yet'), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    expect(find.text('Extra towels'), findsNothing);
  });

  test('status colors follow the docs/06 §2.1 palette', () {
    expect(
      hotelOrderSheetStatusColor(HotelOrderSheetStatus.delivering),
      const Color(0xFFF5A623),
    );
    expect(
      hotelOrderSheetStatusColor(HotelOrderSheetStatus.delivered),
      const Color(0xFF34B36B),
    );
    expect(
      hotelOrderSheetStatusColor(HotelOrderSheetStatus.pending),
      const Color(0xFF8E939C),
    );
    expect(
      hotelOrderSheetStatusColor(HotelOrderSheetStatus.placed),
      hotelOrderSheetStatusColor(HotelOrderSheetStatus.reserved),
    );
    final distinct = HotelOrderSheetStatus.values
        .map(hotelOrderSheetStatusColor)
        .toSet();
    expect(distinct, hasLength(4));
  });
}
