import 'package:flutter/cupertino.dart' hide Text;
import 'package:flutter/material.dart' hide Text;

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'dish_builder.dart';
import 'ready_made.dart';
import '../tr_text.dart';
import '../translation.dart';

/// Saved dishes — everything you've made once, by section.
/// Nothing is created here: dishes are made from a meal (➕) and land here
/// by themselves. Tap one to add a portion to a meal; edit or delete it.
/// Opened from a meal ([meal] set) the portion goes straight to that meal.
class SavedDishesScreen extends StatefulWidget {
  const SavedDishesScreen({super.key, this.meal});
  final Meal? meal;

  @override
  State<SavedDishesScreen> createState() => _SavedDishesScreenState();
}

class _SavedDishesScreenState extends State<SavedDishesScreen> {
  late Category _tab =
      widget.meal == Meal.breakfast || widget.meal == Meal.snack
          ? Category.drinks
          : Category.mains;

  Future<void> _addPortion(Dish dish) async {
    final meal = widget.meal ?? await _pickMeal();
    if (meal == null) return;
    if (!mounted) return;
    final added = await showPortionSheet(context, meal, dish);
    if (!mounted) return;
    if (added == true && widget.meal != null) Navigator.pop(context);
  }

  Future<Meal?> _pickMeal() => showModalBottomSheet<Meal>(
        context: context,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add to which meal?', style: PC.logo(22)),
              const SizedBox(height: 12),
              for (final m in Meal.values.where((m) => m != Meal.water))
                ListTile(
                  leading: IconOnBlack(m.icon, size: 40),
                  title: Text(m.label, style: PC.logo(18)),
                  onTap: () => Navigator.pop(ctx, m),
                ),
            ],
          ),
        ),
      );

  void _edit(Dish dish) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => dish.homemade
              ? DishBuilderScreen(category: dish.category, existing: dish)
              : ReadyMadeScreen(category: dish.category, existing: dish),
        ),
      );

  Future<void> _delete(Dish dish) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${dish.name}"?', style: PC.title(22)),
        content: Text('What you already ate stays in your days.',
            style: PC.body(14, color: PC.textSoft)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Keep')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (yes == true) AppState.instance.deleteDish(dish);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final dishes = s.dishesIn(_tab);
        return PCScaffold(
          title: widget.meal == null
              ? 'My saved dishes'
              : 'Add to ${widget.meal!.label}',
          body: Column(
            children: [
              SizedBox(
                height: 112,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  children: [
                    for (final c in Category.values) _tabChip(c, s),
                  ],
                ),
              ),
              Expanded(
                child: dishes.isEmpty
                    ? _empty()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        children: [
                          Text(
                              widget.meal == null
                                  ? 'Tap a dish to add it to breakfast, lunch, dinner or a snack'
                                  : 'Tap a dish to add your portion',
                              style: PC.body(13, color: PC.textSoft)),
                          const SizedBox(height: 10),
                          for (final d in dishes)
                            _DishCard(
                              dish: d,
                              onTap: () => _addPortion(d),
                              onEdit: () => _edit(d),
                              onDelete: () => _delete(d),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabChip(Category c, AppState s) {
    final on = c == _tab;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _tab = c),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 86,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color:
                on ? PC.gold.withOpacity(0.18) : Colors.white.withOpacity(0.04),
            border: Border.all(
                color: on ? PC.gold : PC.gold.withOpacity(0.2), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconOnBlack(c.icon, size: 40),
              const SizedBox(height: 4),
              // The whole name: one word alone ("Main") translates wrong.
              Text(c.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: PC
                      .body(11,
                          color: on ? PC.goldLight : PC.textSoft,
                          weight: FontWeight.w700)
                      .copyWith(height: 1.1)),
              Text('${s.dishesIn(c).length}',
                  style: PC.body(10, color: PC.textSoft)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty() => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconOnBlack(_tab.icon, size: 96),
            const SizedBox(height: 12),
            Text('Nothing saved in ${_tab.label.toLowerCase()} yet',
                textAlign: TextAlign.center,
                style: PC.title(22, color: PC.text)),
            const SizedBox(height: 8),
            Text(
              'Make a dish from Breakfast, Lunch, Dinner or Snack — it is saved here by itself.',
              textAlign: TextAlign.center,
              style: PC.body(14, color: PC.textSoft),
            ),
          ],
        ),
      );
}

class _DishCard extends StatelessWidget {
  const _DishCard(
      {required this.dish,
      required this.onTap,
      required this.onEdit,
      required this.onDelete});
  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Ink(
            decoration: PC.card(),
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                IconOnBlack(dish.icon, size: 56),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dish.name, style: PC.title(20, color: PC.text)),
                      Text(
                        dish.homemade
                            ? 'Homemade · ${dish.ingredients.length} ingredients'
                            : 'Ready-made',
                        style: PC.body(12, color: PC.textSoft),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(fmt(dish.kcalPerServing ?? dish.kcalPer100),
                        style: PC.body(20,
                            color: PC.goldLight, weight: FontWeight.w700)),
                    Text(
                        dish.byServing
                            ? 'kcal / serving'
                            : 'kcal / 100 ${dish.category.unit}',
                        style: PC.body(11, color: PC.textSoft)),
                  ],
                ),
                IconButton(
                  tooltip: t('Edit'),
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: PC.textSoft),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: t('Delete'),
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: PC.textSoft),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A meal of the selected day: what was eaten. Three ways to add:
/// Product — a food eaten as it is (sour cream, an apple), straight in;
/// Ready-made / Homemade — a new dish, saved to Saved dishes, portion here.
/// A dish made before is picked from Saved dishes.
class MealScreen extends StatelessWidget {
  const MealScreen({super.key, required this.meal});
  final Meal meal;

  Category get _usual => meal == Meal.breakfast || meal == Meal.snack
      ? Category.drinks
      : Category.mains;

  Future<void> _addProduct(BuildContext context) async {
    final p = await pickProduct(context, _usual);
    if (p == null) return;
    if (!context.mounted) return;
    final g = await askAmount(context, p, label: 'How much?');
    if (g == null) return;
    if (!context.mounted) return;
    final e = AppState.instance.addProductEntry(meal, p, g);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Added ${e.kcal.round()} kcal to ${meal.label}')));
  }

  Future<void> _create(BuildContext context, Widget screen) async {
    final dish = await Navigator.push<Dish>(
        context, MaterialPageRoute(builder: (_) => screen));
    if (dish != null && context.mounted) {
      await showPortionSheet(context, meal, dish, justSaved: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final items = s.entriesFor(meal);
        return PCScaffold(
          title: s.isToday
              ? meal.label
              : '${meal.label} · ${dayTitle(s.selected)}',
          bottom: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SavedDishesScreen(meal: meal))),
                icon: const Icon(Icons.menu_book_outlined,
                    color: PC.logoGold, size: 20),
                label: Text('From my saved dishes',
                    style: PC.logo(15, color: PC.logoGoldLight)),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlineButtonPC('Product',
                        icon: Icons.egg_outlined,
                        onPressed: () => _addProduct(context)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlineButtonPC('Ready-made',
                        icon: Icons.shopping_bag_outlined,
                        onPressed: () => _create(
                            context, ReadyMadeScreen(category: _usual))),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlineButtonPC('Homemade',
                        icon: Icons.soup_kitchen_outlined,
                        onPressed: () => _create(
                            context, DishBuilderScreen(category: _usual))),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            children: [
              Center(child: IconOnBlack(meal.icon, size: 96)),
              const SizedBox(height: 8),
              Center(
                child: Text('${s.eatenIn(meal).round()} kcal',
                    style: PC.body(30,
                        color: PC.goldLight, weight: FontWeight.w800)),
              ),
              const SizedBox(height: 6),
              MacrosRow(
                protein: items.fold(0, (t, e) => t + e.protein),
                fat: items.fold(0, (t, e) => t + e.fat),
                carbs: items.fold(0, (t, e) => t + e.carbs),
              ),
              const SizedBox(height: 18),
              if (items.isEmpty)
                Text(
                    'Nothing here yet — make a dish below, or pick one you saved.',
                    textAlign: TextAlign.center,
                    style: PC.body(14, color: PC.textSoft))
              else
                for (final e in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      decoration: PC.card(border: PC.gold.withOpacity(0.3)),
                      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                      child: Row(
                        children: [
                          IconOnBlack(e.icon, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name,
                                    style:
                                        PC.body(15, weight: FontWeight.w600)),
                                Text(amountLabel(e.grams, e.unit),
                                    style: PC.body(13, color: PC.textSoft)),
                              ],
                            ),
                          ),
                          Text('${e.kcal.round()} kcal',
                              style: PC.body(15, color: PC.goldLight)),
                          IconButton(
                            icon: const Icon(Icons.close,
                                size: 18, color: PC.textSoft),
                            onPressed: () => s.removeEntry(e),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

/// "How much did you have?" → exact kcal → add to the meal.
/// Starts at a usual portion, so nobody has to weigh.
/// Returns true when the portion was added.
Future<bool?> showPortionSheet(BuildContext context, Meal meal, Dish dish,
    {bool justSaved = false}) {
  final drink = dish.category == Category.drinks;
  final grams = TextEditingController(text: fmt(dish.standardPortion));
  final label = dish.byServing
      ? 'How many servings?'
      : drink
          ? 'Your cup'
          : 'Your portion';
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheet) {
        final g = parseNum(grams.text);
        final kcal = g == null ? null : dish.kcalFor(g);
        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, 24 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconOnBlack(dish.icon, size: 80),
              const SizedBox(height: 8),
              Text(dish.name, style: PC.title(24)),
              Text(
                  dish.byServing
                      ? '${fmt(dish.kcalPerServing!)} kcal per serving'
                      : '${fmt(dish.kcalPer100)} kcal per 100 ${dish.category.unit}',
                  style: PC.body(13, color: PC.textSoft)),
              const SizedBox(height: 18),
              NumberField(
                controller: grams,
                label: label,
                suffix: dish.byServing ? '×' : dish.category.unit,
                autofocus: true,
                onChanged: (_) => setSheet(() {}),
              ),
              const SizedBox(height: 14),
              if (!dish.byServing) ...[
                const SizedBox(height: 4),
                Text(
                    'A usual ${drink ? 'cup' : 'portion'} — change it if yours is bigger or smaller.',
                    style: PC.body(12, color: PC.textSoft)),
              ],
              const SizedBox(height: 14),
              Text(kcal == null ? '— kcal' : '${kcal.round()} kcal',
                  style: PC.body(34,
                      color: PC.goldLight, weight: FontWeight.w800)),
              if (g != null) ...[
                const SizedBox(height: 6),
                MacrosRow(
                    protein: dish.proteinFor(g),
                    fat: dish.fatFor(g),
                    carbs: dish.carbsFor(g)),
              ],
              const SizedBox(height: 16),
              GoldButton('Add to ${meal.label}',
                  icon: Icons.add,
                  onPressed: (g == null || g <= 0)
                      ? null
                      : () {
                          AppState.instance.addEntry(meal, dish, g);
                          Navigator.pop(sheetContext, true);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(justSaved
                                  ? 'Saved to my saved dishes · ${kcal!.round()} kcal added to ${meal.label}'
                                  : 'Added ${kcal!.round()} kcal to ${meal.label}')));
                        }),
            ],
          ),
        );
      },
    ),
  );
}

/// Water: a gold drop with today's total, and a wheel to pick how much
/// you drank (like the water wheel in Smart Body Life).
class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  static final _values = [for (var v = 50; v <= 1000; v += 50) v];
  int _index = _values.indexOf(250);
  final List<int> _added = []; // for Undo

  void _add(int ml) {
    AppState.instance.addWater(ml);
    setState(() => _added.add(ml));
  }

  void _undo() {
    if (_added.isEmpty) return;
    AppState.instance.addWater(-_added.removeLast());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final goal = s.profile?.waterMl ?? 2000;
        final ml = s.waterDay;
        return PCScaffold(
          title: 'Water',
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Center(
                  child: GoldRimIcon(Icons.water_drop_outlined, size: 96)),
              const SizedBox(height: 14),
              Center(
                child:
                    Text('$ml ml', style: PC.logo(34, color: PC.logoGoldLight)),
              ),
              Center(
                child: Text('of $goal ml today',
                    style: PC.logo(14, color: PC.textSoft)),
              ),
              const SizedBox(height: 10),
              const Center(child: WaterDrops()),
              const SizedBox(height: 18),
              Container(
                decoration: PC.sheenCard(border: PC.logoGold.withOpacity(0.7)),
                padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 150,
                        child: CupertinoPicker(
                          backgroundColor: Colors.transparent,
                          itemExtent: 40,
                          scrollController:
                              FixedExtentScrollController(initialItem: _index),
                          onSelectedItemChanged: (i) =>
                              setState(() => _index = i),
                          selectionOverlay: Container(
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                horizontal: BorderSide(
                                    color: PC.logoGold.withOpacity(0.7)),
                              ),
                            ),
                          ),
                          children: [
                            for (final v in _values)
                              Center(
                                child: Text('$v ml',
                                    style: PC.logo(22, color: PC.craft)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _add(_values[_index]),
                      child: Container(
                        width: 76,
                        height: 76,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: PC.logoGoldGradient,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: PC.emeraldDeep,
                            border:
                                Border.all(color: PC.logoGoldLight, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Text('Add',
                              style: PC.logo(18, color: PC.logoGoldLight)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _quick('+ 500 ml', () => _add(500))),
                  const SizedBox(width: 12),
                  Expanded(child: _quick('+ 1 L', () => _add(1000))),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _added.isEmpty ? null : _undo,
                  child: Text('Undo',
                      style: PC.logo(15,
                          color: _added.isEmpty
                              ? Colors.white24
                              : PC.logoGoldLight)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quick(String label, VoidCallback onTap) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: PC.sheenCard(border: PC.logoGold.withOpacity(0.5)),
          child: Text(label, style: PC.logo(17, color: PC.logoGoldLight)),
        ),
      );
}
