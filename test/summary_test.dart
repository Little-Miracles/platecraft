import 'package:flutter_test/flutter_test.dart';
import 'package:platecraft/models.dart';
import 'package:platecraft/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The caring evening card: which day it talks about and how it reads it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final s = AppState.instance;
  Profile profile(Goal g) => Profile(
      female: true,
      age: 35,
      heightCm: 158,
      weightKg: 78,
      activity: 1.375,
      avatar: 'av_woman',
      goal: g);
  final soup = Dish(
      id: 'x',
      name: 'Soup',
      category: Category.soups,
      icon: 'soups',
      kcalPer100: 100);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await s.load();
    s.entries.clear();
    s.waterByDate.clear();
    s.saveProfile(profile(Goal.health));
  });

  void eat(DateTime day, double grams) {
    s.selectDay(day);
    s.addEntry(Meal.lunch, soup, grams);
  }

  test('the goal changes the target: −15% to lose, +10% to gain', () {
    final base = profile(Goal.health).targetKcal;
    expect(profile(Goal.lose).targetKcal, (base / 1.0 * 0.85).round());
    expect(profile(Goal.gain).targetKcal, closeTo(base * 1.1, 1));
  });

  test('before 20:30 the card is about the last day with meals', () {
    final now = DateTime(2026, 10, 17, 14, 0);
    eat(DateTime(2026, 10, 14), 1000); // logged three days ago
    eat(DateTime(2026, 10, 17), 500); // today, but it's afternoon
    final sum = s.summary(now)!;
    expect(sum.date, DateTime(2026, 10, 14));
    expect(sum.eaten, 1000);
  });

  test('from 20:30 the card is about today; closing hides it', () {
    eat(DateTime(2026, 10, 17), 500);
    expect(s.summary(DateTime(2026, 10, 17, 20, 29)), isNull);
    final sum = s.summary(DateTime(2026, 10, 17, 20, 30))!;
    expect(sum.date, DateTime(2026, 10, 17));
    s.closeSummary(sum);
    expect(s.summary(DateTime(2026, 10, 17, 21, 0)), isNull);
  });

  test('no meals, no card', () {
    expect(s.summary(DateTime(2026, 10, 17, 21, 0)), isNull);
  });

  DaySummary day(Goal g, double eaten, {int water = 0}) => DaySummary(
      date: DateTime(2026, 10, 16),
      eaten: eaten,
      target: 2000,
      water: water,
      waterGoal: 2340,
      goal: g);

  test('lose weight: under is praised, far under is cared for', () {
    expect(day(Goal.lose, 1700).food, contains('Well done'));
    expect(day(Goal.lose, 1000).food, contains('take care of yourself'));
    expect(day(Goal.lose, 2300).food, contains('300 kcal over'));
  });

  test('health and gain: short is a soft reminder', () {
    expect(day(Goal.health, 1500).food, contains('500 kcal short'));
    expect(day(Goal.health, 2000).food, contains('Right on your goal'));
    expect(day(Goal.gain, 1800).food, contains('200 kcal short'));
    expect(day(Goal.gain, 2100).food, contains('reached your goal'));
  });

  test('water always points to the dietitian', () {
    expect(day(Goal.health, 2000, water: 1000).drink, contains('dietitian'));
    expect(day(Goal.health, 2000, water: 2500).drink, contains('dietitian'));
  });
}
