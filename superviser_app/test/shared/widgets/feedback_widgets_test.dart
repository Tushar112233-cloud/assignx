import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superviser_app/shared/widgets/feedback/empty_state.dart';
import 'package:superviser_app/shared/widgets/feedback/error_state.dart';
import 'package:superviser_app/shared/widgets/feedback/shimmer_loading.dart';
import 'package:superviser_app/shared/widgets/feedback/skeleton_loaders.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders with title and description', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              description: 'There are no items to display',
            ),
          ),
        ),
      );

      expect(find.text('No Items'), findsOneWidget);
      expect(find.text('There are no items to display'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('shows action button when provided',
        (WidgetTester tester) async {
      var buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              description: 'There are no items to display',
              actionLabel: 'Add Item',
              onAction: () => buttonPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);

      await tester.tap(find.text('Add Item'));
      await tester.pump();

      expect(buttonPressed, isTrue);
    });
  });

  group('ErrorState', () {
    testWidgets('renders with error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Something went wrong',
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('calls onRetry when retry button is tapped',
        (WidgetTester tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Something went wrong',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retried, isTrue);
    });
  });

  group('ShimmerLoading', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(
              child: SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerLoading), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('can be disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(
              enabled: false,
              child: SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerLoading), findsOneWidget);
    });
  });

  group('ShimmerBox', () {
    testWidgets('renders with specified dimensions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerBox(width: 100, height: 50),
          ),
        ),
      );

      expect(find.byType(ShimmerBox), findsOneWidget);
    });
  });

  group('ShimmerCircle', () {
    testWidgets('renders with specified size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCircle(size: 50),
          ),
        ),
      );

      expect(find.byType(ShimmerCircle), findsOneWidget);
    });
  });

  group('ShimmerListItem', () {
    testWidgets('renders list item skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListItem(),
          ),
        ),
      );

      expect(find.byType(ShimmerListItem), findsOneWidget);
    });

    testWidgets('shows leading circle when hasLeading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListItem(hasLeading: true),
          ),
        ),
      );

      expect(find.byType(ShimmerCircle), findsOneWidget);
    });
  });

  group('Skeleton Loaders', () {
    testWidgets('ProjectCardSkeleton renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProjectCardSkeleton(),
          ),
        ),
      );

      expect(find.byType(ProjectCardSkeleton), findsOneWidget);
    });

    testWidgets('StatsCardSkeleton renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsCardSkeleton(),
          ),
        ),
      );

      expect(find.byType(StatsCardSkeleton), findsOneWidget);
    });

    testWidgets('NotificationSkeleton renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationSkeleton(),
          ),
        ),
      );

      expect(find.byType(NotificationSkeleton), findsOneWidget);
    });

    testWidgets('ChatRoomTileSkeleton renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatRoomTileSkeleton(),
          ),
        ),
      );

      expect(find.byType(ChatRoomTileSkeleton), findsOneWidget);
    });
  });
}
