/// Meals of the day. The icon names point to files in assets/icons/.
enum Meal {
  breakfast('Breakfast', 'breakfast'),
  lunch('Lunch', 'lunch'),
  dinner('Dinner', 'dinner'),
  snack('Snack', 'snack'),
  water('Water', 'water');

  const Meal(this.label, this.icon);
  final String label;
  final String icon;
}

enum Category {
  drinks('Drinks', 'drinks',
      ['drinks', 'tea', 'cocktail', 'milk', 'bubble_tea', 'smoothie', 'water']),
  baked('Baked goods', 'baked', [
    'baked',
    'croissant',
    'bread',
    'cake',
    'pancakes',
    'doughnut',
    'cookie',
    'pie'
  ]),
  soups('Soups', 'soups', ['soups', 'broth', 'noodle_soup', 'paella']),
  mains('Main dishes', 'mains', [
    'mains',
    'curry',
    'spaghetti',
    'salad',
    'chicken',
    'meat',
    'shrimp',
    'fish',
    'rice',
    'burger',
    'sandwich',
    'falafel',
    'egg'
  ]);

  const Category(this.label, this.icon, this.icons);
  final String label;
  final String icon;
  final List<String> icons;

  /// Drinks are measured in ml (1 ml ≈ 1 g), everything else in grams.
  String get unit => this == Category.drinks ? 'ml' : 'g';
}

const avatarIcons = [
  'av_woman',
  'av_man',
  'av_cat',
  'av_fox',
  'av_panda',
  'av_rabbit',
  'av_owl',
  'av_unicorn',
  'av_frog',
  'av_bear',
];

const allDishIcons = [
  'soups',
  'broth',
  'noodle_soup',
  'paella',
  'mains',
  'curry',
  'spaghetti',
  'salad',
  'chicken',
  'meat',
  'shrimp',
  'fish',
  'rice',
  'burger',
  'sandwich',
  'falafel',
  'egg',
  'baked',
  'croissant',
  'bread',
  'cake',
  'pancakes',
  'doughnut',
  'cookie',
  'pie',
  'drinks',
  'tea',
  'cocktail',
  'milk',
  'bubble_tea',
  'smoothie',
  'water',
  'snack',
];

class Activity {
  const Activity(this.label, this.factor);
  final String label;
  final double factor;
}

const activities = [
  Activity('Sedentary — little or no exercise', 1.2),
  Activity('Light — 1–3 workouts a week', 1.375),
  Activity('Moderate — 3–5 workouts a week', 1.55),
  Activity('Active — 6–7 workouts a week', 1.725),
  Activity('Very active — physical job or 2× a day', 1.9),
];

class Profile {
  Profile({
    required this.female,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
    required this.avatar,
  });

  final bool female;
  final int age;
  final double heightCm;
  final double weightKg;
  final double activity;
  final String avatar;

  /// Mifflin–St Jeor basal metabolic rate.
  double get bmr =>
      10 * weightKg + 6.25 * heightCm - 5 * age + (female ? -161 : 5);

  int get targetKcal => (bmr * activity).round();

  /// 30 ml of water per kg of body weight.
  int get waterMl => (weightKg * 30).round();

  Map<String, dynamic> toJson() => {
        'female': female,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'activity': activity,
        'avatar': avatar,
      };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        female: j['female'] as bool,
        age: j['age'] as int,
        heightCm: (j['heightCm'] as num).toDouble(),
        weightKg: (j['weightKg'] as num).toDouble(),
        activity: (j['activity'] as num).toDouble(),
        avatar: j['avatar'] as String,
      );
}

class Product {
  const Product(this.name, this.kcalPer100,
      {this.own = false,
      this.categories = const [],
      this.liquid = false,
      this.tspGrams});
  final String name;
  final double kcalPer100;
  final bool own;

  /// Measured in ml (milk, coffee, juice); 1 ml ≈ 1 g.
  final bool liquid;

  /// Weight of one teaspoon, for sugar, honey, cocoa… (tablespoon = 3×).
  final double? tspGrams;

  String get unit => liquid ? 'ml' : 'g';

  /// Sections this product is typical for: baked, drinks, soups, mains.
  final List<String> categories;

  bool isFor(Category c) => categories.contains(c.name);

  Map<String, dynamic> toJson() => {'name': name, 'kcal': kcalPer100};

  factory Product.fromJson(Map<String, dynamic> j, {bool own = false}) =>
      Product(j['name'] as String, (j['kcal'] as num).toDouble(),
          own: own,
          categories: (j['for'] as List?)?.cast<String>() ?? const [],
          liquid: j['ml'] as bool? ?? false,
          tspGrams: (j['tsp'] as num?)?.toDouble());
}

class Ingredient {
  Ingredient(this.name, this.grams, this.kcalPer100, {this.liquid = false});
  final String name;

  /// Amount in g, or ml for liquids.
  double grams;
  final double kcalPer100;
  final bool liquid;

  String get unit => liquid ? 'ml' : 'g';
  double get kcal => grams * kcalPer100 / 100;

  Map<String, dynamic> toJson() =>
      {'name': name, 'grams': grams, 'kcal': kcalPer100, 'ml': liquid};

  factory Ingredient.fromJson(Map<String, dynamic> j) => Ingredient(
      j['name'] as String,
      (j['grams'] as num).toDouble(),
      (j['kcal'] as num).toDouble(),
      liquid: j['ml'] as bool? ?? false);
}

/// A dish in My Kitchen: either homemade (ingredients + finished weight)
/// or ready-made (just kcal per 100 g from the package).
class Dish {
  Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.kcalPer100,
    this.kcalPerServing,
    this.finishedWeight,
    this.ingredients = const [],
  });

  final String id;
  final String name;
  final Category category;
  final String icon;
  final double kcalPer100;

  /// Set for ready-made items counted by serving ("1 cupcake = 250 kcal").
  final double? kcalPerServing;
  final double? finishedWeight;
  final List<Ingredient> ingredients;

  bool get homemade => ingredients.isNotEmpty;
  bool get byServing => kcalPerServing != null;

  double kcalFor(double amount) =>
      byServing ? kcalPerServing! * amount : kcalPer100 * amount / 100;

  String get unit => byServing ? 'serving' : category.unit;

  /// The exact kernel: everything that went into the pot,
  /// divided by what the pot weighs when it's done.
  static double? per100(List<Ingredient> ingredients, double finishedWeight) {
    if (ingredients.isEmpty || finishedWeight <= 0) return null;
    final total = ingredients.fold<double>(0, (s, i) => s + i.kcal);
    return total / finishedWeight * 100;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'icon': icon,
        'kcalPer100': kcalPer100,
        'kcalPerServing': kcalPerServing,
        'finishedWeight': finishedWeight,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
      };

  factory Dish.fromJson(Map<String, dynamic> j) => Dish(
        id: j['id'] as String,
        name: j['name'] as String,
        category: Category.values.byName(j['category'] as String),
        icon: j['icon'] as String,
        kcalPer100: (j['kcalPer100'] as num).toDouble(),
        kcalPerServing: (j['kcalPerServing'] as num?)?.toDouble(),
        finishedWeight: (j['finishedWeight'] as num?)?.toDouble(),
        ingredients: (j['ingredients'] as List)
            .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Entry {
  Entry({
    required this.id,
    required this.date,
    required this.meal,
    required this.name,
    required this.icon,
    required this.grams,
    required this.kcal,
    this.unit = 'g',
  });

  final String id;
  final String date;
  final Meal meal;
  final String name;
  final String icon;

  /// Amount eaten, in [unit]: g, ml or servings.
  final double grams;
  final double kcal;
  final String unit;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'meal': meal.name,
        'name': name,
        'icon': icon,
        'grams': grams,
        'kcal': kcal,
        'unit': unit,
      };

  factory Entry.fromJson(Map<String, dynamic> j) => Entry(
        id: j['id'] as String,
        date: j['date'] as String,
        meal: Meal.values.byName(j['meal'] as String),
        name: j['name'] as String,
        icon: j['icon'] as String,
        grams: (j['grams'] as num).toDouble(),
        kcal: (j['kcal'] as num).toDouble(),
        unit: j['unit'] as String? ?? 'g',
      );
}
