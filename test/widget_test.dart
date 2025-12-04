import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_sleep/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: NeuroSleepApp()));

    // Verify that the title is present.
    expect(find.text('NeuroSueño'), findsOneWidget);
    expect(find.text('Noche'), findsOneWidget);
    expect(find.text('Siesta'), findsOneWidget);
  });
}
