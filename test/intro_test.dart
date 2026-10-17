import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platecraft/models.dart';
import 'package:platecraft/screens/intro.dart';
import 'package:platecraft/state.dart';
import 'package:platecraft/translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.load();
    await TranslationService.instance.load();
  });

  String typed(WidgetTester tester) => tester
      .widgetList<RichText>(find.byType(RichText))
      .map((r) => r.text.toPlainText())
      .join(' | ');

  testWidgets('intro types the invite, then the result after the calculator',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MaterialApp(home: IntroScreen()));
    for (var i = 0; i < 200; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(typed(tester), contains("let's find your daily calories"));

    await tester.tap(find.byType(GoldenCalculator));
    await tester.pumpAndSettle();
    AppState.instance.saveProfile(Profile(
        female: true,
        age: 35,
        heightCm: 158,
        weightKg: 78,
        activity: 1.375,
        avatar: 'av_woman',
        goal: Goal.lose));
    Navigator.of(tester.element(find.text('Calculator').first)).pop();
    for (var i = 0; i < 300; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    debugPrint('SCREEN: ${typed(tester)}');
    expect(typed(tester), contains('Your daily goal is'));
  });

  testWidgets('switching the language retypes the line', (tester) async {
    AppState.instance.profile = null;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MaterialApp(home: IntroScreen()));
    for (var i = 0; i < 200; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(typed(tester), contains("let's find"));
    TranslationService.instance.fake = (text, from, to) =>
        Future.delayed(const Duration(milliseconds: 300), () => 'UK $text');
    await TranslationService.instance.setLang('uk');
    for (var i = 0; i < 300; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    debugPrint('AFTER: ${typed(tester)}');
    expect(typed(tester), contains("UK First, let's find"));
    await TranslationService.instance.setLang('en');
    TranslationService.instance.fake = null;
  });
}
