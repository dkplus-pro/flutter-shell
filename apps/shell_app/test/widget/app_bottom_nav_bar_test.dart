import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/core/shell/app_bottom_nav_bar.dart';

const _items = [
  AppBottomNavItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: 'Home',
  ),
  AppBottomNavItem(
    icon: Icons.headset_mic_outlined,
    selectedIcon: Icons.headset_mic,
    label: 'Services',
    circleWhenSelected: true,
  ),
  AppBottomNavItem(
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: 'Profile',
  ),
];

Widget _wrap(int currentIndex, ValueChanged<int> onTap) {
  return MaterialApp(
    home: Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        items: _items,
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    ),
  );
}

final Finder purpleCircle = find.byWidgetPredicate(
  (widget) =>
      widget is Container &&
      widget.decoration is BoxDecoration &&
      (widget.decoration! as BoxDecoration).shape == BoxShape.circle &&
      (widget.decoration! as BoxDecoration).color == HotelColors.primary,
);

Finder semanticsFor(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);

void main() {
  testWidgets('renders the three localized items', (tester) async {
    await tester.pumpWidget(_wrap(1, (_) {}));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('tapping an item reports its index', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(_wrap(0, tapped.add));

    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(tapped, [2]);

    await tester.tap(find.text('Services'));
    await tester.pump();
    expect(tapped, [2, 1]);
  });

  testWidgets('the service tab selected state uses the 44dp purple circle', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(1, (_) {}));

    expect(purpleCircle, findsOneWidget);
    final circle = tester.widget<Container>(purpleCircle);
    expect(circle.constraints?.maxWidth, HotelDimens.navCircleSize);
    // The icon inside the circle renders white (docs/06 §3.1).
    final whiteIcon = tester.widget<Icon>(
      find.descendant(of: purpleCircle, matching: find.byType(Icon)),
    );
    expect(whiteIcon.color, Colors.white);
  });

  testWidgets('a non-service selected tab shows no purple circle', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(0, (_) {}));

    expect(purpleCircle, findsNothing);
    final homeIcon = tester.widget<Icon>(
      find.descendant(
        of: semanticsFor('Home'),
        matching: find.byIcon(Icons.home),
      ),
    );
    expect(homeIcon.color, HotelColors.primary);
  });

  testWidgets('unselected items render grey outline icons and grey labels', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(0, (_) {}));

    final profileIcon = tester.widget<Icon>(
      find.descendant(
        of: semanticsFor('Profile'),
        matching: find.byIcon(Icons.person_outline),
      ),
    );
    expect(profileIcon.color, HotelColors.textSecondary);
    final profileLabel = tester.widget<Text>(find.text('Profile'));
    expect(profileLabel.style?.color, HotelColors.textSecondary);
  });

  testWidgets('items expose button/selected semantics with their label', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(1, (_) {}));

    final home = tester.widget<Semantics>(semanticsFor('Home'));
    expect(home.properties.button, isTrue);
    expect(home.properties.selected, isFalse);

    final services = tester.widget<Semantics>(semanticsFor('Services'));
    expect(services.properties.button, isTrue);
    expect(services.properties.selected, isTrue);
  });
}
