// Basic Flutter widget test for DOER app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doer_app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: DoerApp(),
      ),
    );

    // Verify that the app starts without errors.
    expect(find.text('DOER'), findsOneWidget);
  });
}
