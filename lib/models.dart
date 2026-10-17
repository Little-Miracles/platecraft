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

  /// A usual portion, so nobody has to weigh: a cup, a bowl, a plate, a slice.
  double get standardPortion => switch (this) {
        Category.drinks => 250,
        Category.soups => 300,
        Category.mains => 250,
        Category.baked => 100,
      };

  /// How this kind of dish is usually cooked.
  Cooking get usualCooking => switch (this) {
        Category.drinks => Cooking.none,
        Category.soups => Cooking.boiled,
        Category.mains => Cooking.stewed,
        Category.baked => Cooking.baked,
      };
}

/// How a dish is cooked, and how much of its raw weight is left after:
/// water boils off a soup (уварка), meat shrinks in the pan (ужарка),
/// dough loses moisture in the oven (упёк). Averages from cooking tables —
/// the finished weight can always be corrected by the cook.
enum Cooking {
  none('No cooking', 1.0, 'mixed, blended or raw — weight stays the same'),
  boiled('Boiled · soup', 0.9, 'about 10% of the water boils off'),
  stewed('Stewed', 0.85, 'about 15% is lost while it simmers'),
  fried('Fried', 0.75, 'about 25% is lost in the pan'),
  baked('Baked', 0.85, 'about 15% of the moisture leaves in the oven');

  const Cooking(this.label, this.yieldFactor, this.note);
  final String label;
  final double yieldFactor;
  final String note;
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

/// One piece of a countable product: "Medium · 7.5 cm · 180 g".
/// Nobody weighs an egg — people pick a size by eye.
class Piece {
  const Piece(this.label, this.grams, [this.hint]);
  final String label;
  final double grams;

  /// Rough size to compare with, e.g. "7.5 cm" across an apple.
  final String? hint;

  factory Piece.fromJson(List<dynamic> j) => Piece(j[0] as String,
      (j[1] as num).toDouble(), j.length > 2 ? j[2] as String? : null);
}

class Product {
  const Product(this.name, this.kcalPer100,
      {this.protein = 0,
      this.fat = 0,
      this.carbs = 0,
      this.own = false,
      this.categories = const [],
      this.liquid = false,
      this.tspGrams,
      this.pieces = const []});
  final String name;
  final double kcalPer100;

  /// Protein, fat and carbs per 100 g (or ml).
  final double protein;
  final double fat;
  final double carbs;
  final bool own;

  /// Measured in ml (milk, coffee, juice); 1 ml ≈ 1 g.
  final bool liquid;

  /// Weight of one teaspoon, for sugar, honey, cocoa… (tablespoon = 3×).
  final double? tspGrams;

  /// Sizes of one piece (egg, apple, potato…), edible weight.
  final List<Piece> pieces;

  String get unit => liquid ? 'ml' : 'g';

  /// Sections this product is typical for: baked, drinks, soups, mains.
  final List<String> categories;

  bool isFor(Category c) => categories.contains(c.name);

  /// A picture for a product eaten as it is (sour cream, an apple…).
  String get icon {
    final n = name.toLowerCase();
    for (final (words, icon) in const [
      (['egg'], 'egg'),
      (['bread'], 'bread'),
      (['salmon', 'cod'], 'fish'),
      (['shrimp'], 'shrimp'),
      (['chicken', 'turkey'], 'chicken'),
      (['beef', 'pork', 'veal', 'minced'], 'meat'),
      (['rice', 'buckwheat', 'bulgur', 'oat', 'semolina'], 'rice'),
      (['pasta', 'noodles'], 'spaghetti'),
      (['tea'], 'tea'),
      (['coffee', 'juice'], 'drinks'),
      (
        ['milk', 'kefir', 'yogurt', 'cream', 'cheese', 'mascarpone', 'butter'],
        'milk'
      ),
      (['chocolate', 'cookie', 'jam', 'honey', 'ice cream'], 'cookie'),
      // The "snack" picture is an apple.
      (
        [
          'apple',
          'pear',
          'peach',
          'orange',
          'banana',
          'kiwi',
          'lemon',
          'cherr',
          'berr',
          'raisin'
        ],
        'snack'
      ),
    ]) {
      if (words.any(n.contains)) return icon;
    }
    return 'salad';
  }

  Map<String, dynamic> toJson() =>
      {'name': name, 'kcal': kcalPer100, 'p': protein, 'f': fat, 'c': carbs};

  factory Product.fromJson(Map<String, dynamic> j, {bool own = false}) =>
      Product(j['name'] as String, (j['kcal'] as num).toDouble(),
          protein: _num(j['p']),
          fat: _num(j['f']),
          carbs: _num(j['c']),
          own: own,
          categories: (j['for'] as List?)?.cast<String>() ?? const [],
          liquid: j['ml'] as bool? ?? false,
          tspGrams: (j['tsp'] as num?)?.toDouble(),
          pieces: [
            for (final p in (j['pcs'] as List?) ?? const [])
              Piece.fromJson(p as List)
          ]);
}

double _num(Object? v) => (v as num?)?.toDouble() ?? 0;

class Ingredient {
  Ingredient(this.name, this.grams, this.kcalPer100,
      {this.liquid = false,
      this.proteinPer100 = 0,
      this.fatPer100 = 0,
      this.carbsPer100 = 0});

  Ingredient.of(Product p, this.grams)
      : name = p.name,
        kcalPer100 = p.kcalPer100,
        liquid = p.liquid,
        proteinPer100 = p.protein,
        fatPer100 = p.fat,
        carbsPer100 = p.carbs;

  final String name;

  /// Amount in g, or ml for liquids.
  double grams;
  final double kcalPer100;
  final bool liquid;
  final double proteinPer100;
  final double fatPer100;
  final double carbsPer100;

  String get unit => liquid ? 'ml' : 'g';
  double get kcal => grams * kcalPer100 / 100;
  double get protein => grams * proteinPer100 / 100;
  double get fat => grams * fatPer100 / 100;
  double get carbs => grams * carbsPer100 / 100;

  Ingredient copy() => Ingredient(name, grams, kcalPer100,
      liquid: liquid,
      proteinPer100: proteinPer100,
      fatPer100: fatPer100,
      carbsPer100: carbsPer100);

  Map<String, dynamic> toJson() => {
        'name': name,
        'grams': grams,
        'kcal': kcalPer100,
        'ml': liquid,
        'p': proteinPer100,
        'f': fatPer100,
        'c': carbsPer100,
      };

  factory Ingredient.fromJson(Map<String, dynamic> j) => Ingredient(
      j['name'] as String,
      (j['grams'] as num).toDouble(),
      (j['kcal'] as num).toDouble(),
      liquid: j['ml'] as bool? ?? false,
      proteinPer100: _num(j['p']),
      fatPer100: _num(j['f']),
      carbsPer100: _num(j['c']));
}

/// A saved dish: either homemade (ingredients + finished weight)
/// or ready-made (numbers from the package).
class Dish {
  Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.kcalPer100,
    this.proteinPer100 = 0,
    this.fatPer100 = 0,
    this.carbsPer100 = 0,
    this.kcalPerServing,
    this.finishedWeight,
    this.cooking,
    this.ingredients = const [],
  });

  final String id;
  final String name;
  final Category category;
  final String icon;
  final double kcalPer100;

  /// Per 100 g/ml — or per serving when [byServing].
  final double proteinPer100;
  final double fatPer100;
  final double carbsPer100;

  /// Set for ready-made items counted by serving ("1 cupcake = 250 kcal").
  final double? kcalPerServing;
  final double? finishedWeight;
  final Cooking? cooking;
  final List<Ingredient> ingredients;

  bool get homemade => ingredients.isNotEmpty;
  bool get byServing => kcalPerServing != null;

  double _scale(double amount) => byServing ? amount : amount / 100;

  double kcalFor(double amount) =>
      byServing ? kcalPerServing! * amount : kcalPer100 * amount / 100;
  double proteinFor(double amount) => proteinPer100 * _scale(amount);
  double fatFor(double amount) => fatPer100 * _scale(amount);
  double carbsFor(double amount) => carbsPer100 * _scale(amount);

  String get unit => byServing ? 'serving' : category.unit;

  /// What lands in the meal unless you change it: one serving; a homemade
  /// drink is the cup you made; otherwise a usual portion of this kind.
  double get standardPortion {
    if (byServing) return 1;
    final w = finishedWeight;
    if (category == Category.drinks && w != null && w <= 500) return w;
    return category.standardPortion;
  }

  /// Raw weight × how much is left after cooking.
  static double theoreticalWeight(List<Ingredient> ingredients, Cooking c) =>
      ingredients.fold<double>(0, (s, i) => s + i.grams) * c.yieldFactor;

  /// The exact kernel: everything that went into the pot,
  /// divided by what the pot weighs when it's done.
  static double? per100(List<Ingredient> ingredients, double finishedWeight,
      [double Function(Ingredient) of = _kcalOf]) {
    if (ingredients.isEmpty || finishedWeight <= 0) return null;
    final total = ingredients.fold<double>(0, (s, i) => s + of(i));
    return total / finishedWeight * 100;
  }

  static double _kcalOf(Ingredient i) => i.kcal;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'icon': icon,
        'kcalPer100': kcalPer100,
        'p': proteinPer100,
        'f': fatPer100,
        'c': carbsPer100,
        'kcalPerServing': kcalPerServing,
        'finishedWeight': finishedWeight,
        'cooking': cooking?.name,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
      };

  factory Dish.fromJson(Map<String, dynamic> j) => Dish(
        id: j['id'] as String,
        name: j['name'] as String,
        category: Category.values.byName(j['category'] as String),
        icon: j['icon'] as String,
        kcalPer100: (j['kcalPer100'] as num).toDouble(),
        proteinPer100: _num(j['p']),
        fatPer100: _num(j['f']),
        carbsPer100: _num(j['c']),
        kcalPerServing: (j['kcalPerServing'] as num?)?.toDouble(),
        finishedWeight: (j['finishedWeight'] as num?)?.toDouble(),
        cooking: j['cooking'] == null
            ? null
            : Cooking.values.byName(j['cooking'] as String),
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
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
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
  final double protein;
  final double fat;
  final double carbs;
  final String unit;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'meal': meal.name,
        'name': name,
        'icon': icon,
        'grams': grams,
        'kcal': kcal,
        'p': protein,
        'f': fat,
        'c': carbs,
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
        protein: _num(j['p']),
        fat: _num(j['f']),
        carbs: _num(j['c']),
        unit: j['unit'] as String? ?? 'g',
      );
}
