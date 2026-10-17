import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platecraft/models.dart';
import 'package:platecraft/screens/calculator.dart';
import 'package:platecraft/screens/day_kitchen.dart';
import 'package:platecraft/screens/dish_builder.dart';
import 'package:platecraft/screens/meals.dart';
import 'package:platecraft/screens/ready_made.dart';
import 'package:platecraft/screens/start_home.dart';
import 'package:platecraft/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.load();
    AppState.instance.saveProfile(Profile(
        female: true,
        age: 35,
        heightCm: 158,
        weightKg: 78,
        activity: 1.375,
        avatar: 'av_woman'));
  });

  for (final size in [const Size(390, 844), const Size(360, 640)]) {
    for (final entry in {
      'home': const HomeScreen(),
      'kitchen': const DayKitchenScreen(),
      'calculator': const CalculatorScreen(),
      'breakfast': const MealScreen(meal: Meal.breakfast),
      'saved dishes': const SavedDishesScreen(),
      'homemade': const DishBuilderScreen(category: Category.soups),
      'ready-made': const ReadyMadeScreen(category: Category.drinks),
    }.entries) {
      testWidgets('${entry.key} lays out at $size', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(MaterialApp(home: entry.value));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
