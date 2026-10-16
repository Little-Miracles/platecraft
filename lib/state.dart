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
    ownProducts.insert(0, Product(p.name, p.kcalPer100, own: true));
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

  Entry addEntry(Meal meal, Dish dish, double grams) {
    final e = Entry(
      id: newId(),
      date: day,
      meal: meal,
      name: dish.name,
      icon: dish.icon,
      grams: grams,
      kcal: dish.kcalFor(grams),
      unit: dish.unit,
    );
    entries.add(e);
    _save('entries', entries.map((x) => x.toJson()).toList());
    return e;
  }

  void removeEntry(Entry e) {
    entries.removeWhere((x) => x.id == e.id);
    _save('entries', entries.map((x) => x.toJson()).toList());
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
