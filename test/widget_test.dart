import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gema/main.dart';

void main() {
  testWidgets('GEMA App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: GemaApp(),
      ),
    );

    // Verify that the dashboard is loaded.
    expect(find.text('GEMA Dashboard'), findsOneWidget);
  });
}
