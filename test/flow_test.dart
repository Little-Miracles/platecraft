import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platecraft/models.dart';
import 'package:platecraft/screens/start_home.dart';
import 'package:platecraft/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The two flows: a dish made from a meal is saved and its portion lands in
/// the meal — calories, protein, fat and carbs reach the day (home banner).
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.load();
  });

  test('borscht: estimated weight, per 100 g, standard portion, day totals',
      () {
    final s = AppState.instance;
    Product p(String name) =>
        s.builtInProducts.firstWhere((x) => x.name == name);
    final items = [
      Ingredient.of(p('Water'), 2000),
      Ingredient.of(p('Beetroot'), 400),
      Ingredient.of(p('Potato'), 400),
      Ingredient.of(p('Beef'), 500),
      Ingredient.of(p('Sunflower oil'), 30),
    ];
    final weight = Dish.theoreticalWeight(items, Cooking.boiled);
    expect(weight, closeTo(3330 * 0.9, 0.01));

    final dish = Dish(
      id: 'b',
      name: 'My borscht',
      category: Category.soups,
      icon: 'soups',
      kcalPer100: Dish.per100(items, weight)!,
      proteinPer100: Dish.per100(items, weight, (i) => i.protein)!,
      fatPer100: Dish.per100(items, weight, (i) => i.fat)!,
      carbsPer100: Dish.per100(items, weight, (i) => i.carbs)!,
      finishedWeight: weight,
      cooking: Cooking.boiled,
      ingredients: items,
    );
    s.saveDish(dish);
    expect(s.dishes, hasLength(1));
    expect(dish.standardPortion, 300);

    final totalKcal = items.fold<double>(0, (t, i) => t + i.kcal);
    s.addEntry(Meal.lunch, dish, dish.standardPortion);
    expect(s.eatenDay, closeTo(totalKcal * 300 / weight, 0.01));
    expect(s.proteinDay, greaterThan(0));
    expect(s.fatDay, greaterThan(0));
    expect(s.carbsDay, greaterThan(0));

    // Deleting the saved dish keeps what was already eaten.
    s.deleteDish(dish);
    expect(s.dishes, isEmpty);
    expect(s.eatenDay, greaterThan(0));
  });

  test('a product eaten as it is goes straight into the meal', () {
    final s = AppState.instance;
    final cream =
        s.builtInProducts.firstWhere((x) => x.name == 'Sour cream 15%');
    final before = s.eatenIn(Meal.lunch);
    final dishes = s.dishes.length;
    final e = s.addProductEntry(Meal.lunch, cream, cream.tspGrams! * 3 * 2);
    expect(e.kcal, closeTo(e.grams * 162 / 100, 0.01));
    expect(e.fat, greaterThan(0));
    expect(e.icon, 'milk');
    Product p(String n) => s.builtInProducts.firstWhere((x) => x.name == n);
    expect(p('Apple').icon, 'snack'); // the apple picture
    expect(p('Apple juice').icon, 'drinks');
    expect(p('Potato').icon, 'salad');
    expect(s.eatenIn(Meal.lunch), closeTo(before + e.kcal, 0.01));
    expect(s.dishes.length, dishes, reason: 'products are not saved as dishes');
  });

  test('countable products have sizes to pick by eye', () {
    final egg =
        AppState.instance.builtInProducts.firstWhere((x) => x.name == 'Egg');
    expect(egg.pieces.map((p) => p.label), ['Small', 'Medium', 'Large']);
    expect(egg.pieces[1].grams, 51);
    final apple =
        AppState.instance.builtInProducts.firstWhere((x) => x.name == 'Apple');
    expect(apple.pieces.last.hint, '8.5 cm');
  });

  test('a homemade cup of coffee is added whole', () {
    final cup = Dish(
        id: 'c',
        name: 'Coffee',
        category: Category.drinks,
        icon: 'drinks',
        kcalPer100: 9,
        finishedWeight: 180,
        cooking: Cooking.none,
        ingredients: [Ingredient('Coffee', 180, 9, liquid: true)]);
    expect(cup.standardPortion, 180);
  });

  test('water reaches the day', () {
    final s = AppState.instance;
    final before = s.waterDay;
    s.addWater(250);
    expect(s.waterDay, before + 250);
  });

  test('old saved data (no macros, no cooking) still loads', () {
    final d = Dish.fromJson({
      'id': 'o',
      'name': 'Old',
      'category': 'mains',
      'icon': 'mains',
      'kcalPer100': 120,
      'finishedWeight': 800,
      'ingredients': [
        {'name': 'Rice (dry)', 'grams': 200, 'kcal': 360}
      ],
    });
    expect(d.cooking, isNull);
    expect(d.proteinPer100, 0);
    expect(
        Entry.fromJson({
          'id': 'e',
          'date': '2026-10-16',
          'meal': 'lunch',
          'name': 'Old',
          'icon': 'mains',
          'grams': 100,
          'kcal': 120,
        }).protein,
        0);
  });

  // The bug from 16.10: the week strip and the drops are const on home and
  // did not hear new meals or water until the screen was opened again.
  testWidgets('home week strip and drops update at once', (tester) async {
    final s = AppState.instance;
    s.saveProfile(Profile(
        female: true,
        age: 35,
        heightCm: 158,
        weightKg: 78,
        activity: 1.375,
        avatar: 'av_woman'));
    s.entries.clear();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    expect(find.text('No meals logged this week yet'), findsOneWidget);

    final cup = Dish(
        id: 'w',
        name: 'Coffee',
        category: Category.drinks,
        icon: 'drinks',
        kcalPer100: 24);
    s.addEntry(Meal.breakfast, cup, 250);
    final ml = s.waterDay;
    s.addWater(250);
    await tester.pump();
    expect(find.text('No meals logged this week yet'), findsNothing);
    expect(find.text('60'), findsWidgets);
    expect(find.text('${ml + 250} / ${s.profile!.waterMl} ml'), findsOneWidget);
  });
}
