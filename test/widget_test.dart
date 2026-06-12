// This is a basic Flutter widget test for Sky Roster app.
import 'package:flutter_test/flutter_test.dart';
import 'package:air_line_app_1/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SkyRosterApp());

    // Verify that the login page is loaded.
    expect(find.text('Sky Roster'), findsOneWidget);
  });
}

