import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gymbuddy_app/main.dart';
import 'package:gymbuddy_app/providers/app_state.dart';

void main() {
  testWidgets('GymBuddyApp renders initial splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const GymBuddyApp(),
      ),
    );

    // Verify brand title renders on splash
    expect(find.text('GYMBUDDY'), findsOneWidget);

    // Advance timer past splash duration to settle pending timers
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
  });
}
