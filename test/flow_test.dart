import 'package:flutter_test/flutter_test.dart';
import 'package:platecraft/models.dart';
import 'package:platecraft/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The two flows: a dish made from a meal is saved and its portion lands in
/// the meal — calories, protein, fat and carbs reach the day (home banner).
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
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
}
