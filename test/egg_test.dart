import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platecraft/models.dart';
import 'package:platecraft/screens/dish_builder.dart';
import 'package:platecraft/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.load();
  });

  testWidgets('picking Egg offers sizes', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
        const MaterialApp(home: DishBuilderScreen(category: Category.mains)));
    await tester.tap(find.text('Add ingredient').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Egg');
    await tester.pumpAndSettle();
    debugPrint([
      for (final w in tester.widgetList<Text>(find.byType(Text))) w.data ?? ''
    ].where((t) => t.contains('Egg') || t.contains('egg')).join(' | '));
    await tester.tap(find.widgetWithText(ListTile, 'Egg').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('+1 medium'), findsOneWidget);
  });
}
