import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:students_app/app.dart';
import 'package:students_app/core/providers/shared_prefs_provider.dart';

void main() {
  testWidgets('ChronoStyle renders header', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ChronoStyleApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('COUNTDOWN'), findsOneWidget);
  });
}
