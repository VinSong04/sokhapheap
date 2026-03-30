import 'package:flutter_test/flutter_test.dart';

import 'package:run_tracker/main.dart';

void main() {
  testWidgets('App renders home screen with bottom navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RunTrackerApp());
    await tester.pumpAndSettle();

    // Verify bottom navigation items are present.
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });
}
