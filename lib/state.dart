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
    profile = p == null ? null : Profile.fromJson(jsonDecode(p));

    dishes = _list('dishes').map(Dish.fromJson).toList();
    ownProducts = _list('ownProducts')
        .map((j) => Product.fromJson(j, own: true))
        .toList();
    entries = _list('entries').map(Entry.fromJson).toList();

    final w = _prefs.getString('water');
    waterByDate = w == null
        ? {}
        : (jsonDecode(w) as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, v as int));
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

  // ---- Backup ----
  /// Everything in one file: profile, dishes, own products, every day's
  /// meals and water. Saved by the person, opened again on a new phone.
  Map<String, dynamic> backup() => {
        'app': 'PlateCraft',
        'version': 1,
        'saved': DateTime.now().toIso8601String(),
        'profile': profile?.toJson(),
        'dishes': dishes.map((d) => d.toJson()).toList(),
        'ownProducts': ownProducts.map((p) => p.toJson()).toList(),
        'entries': entries.map((e) => e.toJson()).toList(),
        'water': waterByDate,
      };

  String backupFileName([DateTime? now]) =>
      'PlateCraft-backup-${key(now ?? DateTime.now())}.json';

  /// Replaces everything with a backup. Throws [FormatException] if the file
  /// isn't a PlateCraft backup — then nothing is changed.
  void restore(Map<String, dynamic> j) {
    if (j['app'] != 'PlateCraft') {
      throw const FormatException('Not a PlateCraft backup');
    }
    List<Map<String, dynamic>> list(String k) =>
        ((j[k] as List?) ?? const []).cast<Map<String, dynamic>>();
    // Read everything first, so a broken file changes nothing.
    final p = j['profile'] == null
        ? null
        : Profile.fromJson(j['profile'] as Map<String, dynamic>);
    final d = list('dishes').map(Dish.fromJson).toList();
    final o =
        list('ownProducts').map((x) => Product.fromJson(x, own: true)).toList();
    final e = list('entries').map(Entry.fromJson).toList();
    final w = ((j['water'] as Map?) ?? const {})
        .map((k, v) => MapEntry(k as String, (v as num).toInt()));

    profile = p;
    dishes = d;
    ownProducts = o;
    entries = e;
    waterByDate = w;
    if (p == null) {
      _prefs.remove('profile');
    } else {
      _prefs.setString('profile', jsonEncode(p.toJson()));
    }
    _prefs.setString('dishes', jsonEncode(d.map((x) => x.toJson()).toList()));
    _prefs.setString(
        'ownProducts', jsonEncode(o.map((x) => x.toJson()).toList()));
    _prefs.setString('entries', jsonEncode(e.map((x) => x.toJson()).toList()));
    _save('water', w);
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
