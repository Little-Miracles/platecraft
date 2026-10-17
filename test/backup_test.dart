import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:platecraft/models.dart';
import 'package:platecraft/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Backup: everything goes into one file and comes back on a new phone.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final s = AppState.instance;

  test('a backup brings back profile, dishes, own products, days and water',
      () async {
    SharedPreferences.setMockInitialValues({});
    await s.load();
    s.saveProfile(Profile(
        female: true,
        age: 35,
        heightCm: 158,
        weightKg: 78,
        activity: 1.375,
        avatar: 'av_fox',
        goal: Goal.lose));
    final soup = Dish(
        id: 'b',
        name: 'Borscht',
        category: Category.soups,
        icon: 'soups',
        kcalPer100: 68.6,
        proteinPer100: 3,
        cooking: Cooking.boiled,
        finishedWeight: 3000,
        ingredients: [Ingredient('Beetroot', 400, 43, carbsPer100: 9.6)]);
    s.saveDish(soup);
    s.addOwnProduct(const Product('Ginger root', 80, protein: 1.8));
    s.addEntry(Meal.lunch, soup, 300);
    s.addWater(750);
    // Through text, as the file would be.
    final file = jsonEncode(s.backup());

    // A new phone: empty app.
    SharedPreferences.setMockInitialValues({});
    await s.load();
    expect(s.profile, isNull);
    expect(s.dishes, isEmpty);

    s.restore(jsonDecode(file) as Map<String, dynamic>);
    expect(s.profile!.goal, Goal.lose);
    expect(s.profile!.avatar, 'av_fox');
    expect(s.dishes.single.name, 'Borscht');
    expect(s.dishes.single.ingredients.single.carbsPer100, 9.6);
    expect(s.ownProducts.single.protein, 1.8);
    expect(s.entries.single.kcal, closeTo(205.8, 0.01));
    expect(s.waterByDate.values.single, 750);

    // And it survives a restart (saved, not only in memory).
    await s.load();
    expect(s.dishes.single.name, 'Borscht');
    expect(s.profile!.goal, Goal.lose);
  });

  test('a file that is not a PlateCraft backup changes nothing', () async {
    SharedPreferences.setMockInitialValues({});
    await s.load();
    s.addWater(250);
    expect(() => s.restore({'hello': 1}), throwsFormatException);
    expect(s.waterDay, 250);
  });

  test('the file name carries the date', () {
    expect(s.backupFileName(DateTime(2026, 10, 17)),
        'PlateCraft-backup-2026-10-17.json');
  });
}
