import 'dart:convert';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// The kitchen brain: holds everything, does the math, saves to the browser.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  late SharedPreferences _prefs;

  Profile? profile;
  List<Dish> dishes = [];
  List<Product> builtInProducts = [];
  List<Product> ownProducts = [];
  List<Entry> entries = [];
  Map<String, int> waterByDate = {};

  static String key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String today() => key(DateTime.now());

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// The day the home screen shows and new entries go to.
  DateTime selected = dateOnly(DateTime.now());
  String get day => key(selected);
  bool get isToday => day == today();

  void selectDay(DateTime d) {
    selected = dateOnly(d);
    notifyListeners();
  }

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();

    final raw = await rootBundle.loadString('assets/data/products.json');
    builtInProducts = (jsonDecode(raw) as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    final p = _prefs.getString('profile');
    if (p != null) profile = Profile.fromJson(jsonDecode(p));

    dishes = _list('dishes').map(Dish.fromJson).toList();
    ownProducts = _list('ownProducts')
        .map((j) => Product.fromJson(j, own: true))
        .toList();
    entries = _list('entries').map(Entry.fromJson).toList();

    final w = _prefs.getString('water');
    if (w != null) {
      waterByDate = (jsonDecode(w) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as int));
    }
  }

  List<Map<String, dynamic>> _list(String key) {
    final s = _prefs.getString(key);
    if (s == null) return [];
    return (jsonDecode(s) as List).cast<Map<String, dynamic>>();
  }

  void _save(String key, Object value) {
    _prefs.setString(key, jsonEncode(value));
    notifyListeners();
  }

  // ---- Profile ----
  void saveProfile(Profile p) {
    profile = p;
    _save('profile', p.toJson());
  }

  // ---- My Kitchen ----
  List<Dish> dishesIn(Category c) =>
      dishes.where((d) => d.category == c).toList().reversed.toList();

  void saveDish(Dish dish) {
    final i = dishes.indexWhere((d) => d.id == dish.id);
    if (i >= 0) {
      dishes[i] = dish;
    } else {
      dishes.add(dish);
    }
    _save('dishes', dishes.map((d) => d.toJson()).toList());
  }

  void deleteDish(Dish dish) {
    dishes.removeWhere((d) => d.id == dish.id);
    _save('dishes', dishes.map((d) => d.toJson()).toList());
  }

  // ---- Products ----
  List<Product> get allProducts => [...ownProducts, ...builtInProducts];

  void addOwnProduct(Product p) {
    ownProducts
        .removeWhere((o) => o.name.toLowerCase() == p.name.toLowerCase());
    ownProducts.insert(
        0,
        Product(p.name, p.kcalPer100,
            protein: p.protein, fat: p.fat, carbs: p.carbs, own: true));
    _save('ownProducts', ownProducts.map((o) => o.toJson()).toList());
  }

  // ---- Selected day ----
  List<Entry> get dayEntries => entries.where((e) => e.date == day).toList();

  List<Entry> entriesFor(Meal m) =>
      dayEntries.where((e) => e.meal == m).toList();

  double get eatenDay => dayEntries.fold(0, (s, e) => s + e.kcal);

  double eatenOn(DateTime d) {
    final k = key(d);
    return entries.where((e) => e.date == k).fold(0, (s, e) => s + e.kcal);
  }

  double eatenIn(Meal m) => entriesFor(m).fold(0, (s, e) => s + e.kcal);

  double get proteinDay => dayEntries.fold(0, (s, e) => s + e.protein);
  double get fatDay => dayEntries.fold(0, (s, e) => s + e.fat);
  double get carbsDay => dayEntries.fold(0, (s, e) => s + e.carbs);

  Entry addEntry(Meal meal, Dish dish, double grams) {
    final e = Entry(
      id: newId(),
      date: day,
      meal: meal,
      name: dish.name,
      icon: dish.icon,
      grams: grams,
      kcal: dish.kcalFor(grams),
      protein: dish.proteinFor(grams),
      fat: dish.fatFor(grams),
      carbs: dish.carbsFor(grams),
      unit: dish.unit,
    );
    entries.add(e);
    _save('entries', entries.map((x) => x.toJson()).toList());
    return e;
  }

  /// A product eaten as it is — sour cream to the borscht, an apple.
  Entry addProductEntry(Meal meal, Product p, double grams) {
    final e = Entry(
      id: newId(),
      date: day,
      meal: meal,
      name: p.name,
      icon: p.icon,
      grams: grams,
      kcal: grams * p.kcalPer100 / 100,
      protein: grams * p.protein / 100,
      fat: grams * p.fat / 100,
      carbs: grams * p.carbs / 100,
      unit: p.unit,
    );
    entries.add(e);
    _save('entries', entries.map((x) => x.toJson()).toList());
    return e;
  }

  void removeEntry(Entry e) {
    entries.removeWhere((x) => x.id == e.id);
    _save('entries', entries.map((x) => x.toJson()).toList());
  }

  // ---- Evening summary ----
  /// From 20:30 the day is summed up on home.
  static const summaryHour = 20, summaryMinute = 30;

  /// The day the caring card talks about: today after 20:30, otherwise the
  /// last day with meals — even if the app wasn't opened for a few days.
  /// Hidden once the person closes it.
  DaySummary? summary([DateTime? clock]) {
    final now = clock ?? DateTime.now();
    final p = profile;
    if (p == null) return null;
    final today = key(now);
    final evening = now.hour > summaryHour ||
        (now.hour == summaryHour && now.minute >= summaryMinute);
    final days = entries.map((e) => e.date).toSet().toList()..sort();
    final logged =
        days.where((d) => d.compareTo(today) < 0 || (d == today && evening));
    if (logged.isEmpty) return null;
    final d = logged.last;
    if (_prefs.getString('summaryClosed') == d) return null;
    return DaySummary(
      date: DateTime.parse(d),
      eaten: entries.where((e) => e.date == d).fold(0, (s, e) => s + e.kcal),
      target: p.targetKcal,
      water: waterByDate[d] ?? 0,
      waterGoal: p.waterMl,
      goal: p.goal,
    );
  }

  void closeSummary(DaySummary s) {
    _prefs.setString('summaryClosed', key(s.date));
    notifyListeners();
  }

  // ---- Water ----
  static const glassMl = 250;

  int get waterDay => waterByDate[day] ?? 0;

  void addWater(int ml) {
    final v = (waterDay + ml).clamp(0, 20000);
    waterByDate[day] = v;
    _save('water', waterByDate);
  }
}
