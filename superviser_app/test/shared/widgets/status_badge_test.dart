import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_test/flutter_test.dart';
import 'package:superviser_app/shared/widgets/misc/status_badge.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('renders with correct status text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'active'),
          ),
        ),
      );

      // Status is formatted with capitalization
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('formats status with underscores correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'in_progress'),
          ),
        ),
      );

      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('applies container decoration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'active'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(decoration?.borderRadius, isNotNull);
    });

    testWidgets('uses different sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge(
                  status: 'normal',
                  size: StatusBadgeSize.medium,
                ),
                StatusBadge(
                  status: 'small',
                  size: StatusBadgeSize.small,
                ),
              ],
            ),
          ),
        ),
      );

      // Find both badges
      final badges = find.byType(StatusBadge);
      expect(badges, findsNWidgets(2));
    });
  });

  group('Badge', () {
    testWidgets('renders with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Badge(label: 'New'),
          ),
        ),
      );

      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('applies custom color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Badge(
              label: 'Test',
              color: Colors.red,
            ),
          ),
        ),
      );

      expect(find.byType(Badge), findsOneWidget);
    });
  });

  group('CountBadge', () {
    testWidgets('renders with count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CountBadge(count: 5),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows max+ when count exceeds maxCount',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CountBadge(count: 150, maxCount: 99),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('hides when count is 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CountBadge(count: 0),
          ),
        ),
      );

      expect(find.byType(CountBadge), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });
}
