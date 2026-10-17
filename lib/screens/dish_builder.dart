import 'package:flutter/material.dart' hide Text;

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import '../tr_text.dart';
import '../translation.dart';

/// Homemade dish: ingredients in grams + how it's cooked → the finished
/// weight (estimated, or weighed) → exact kcal per 100 g. Saved to Saved dishes.
class DishBuilderScreen extends StatefulWidget {
  const DishBuilderScreen({super.key, required this.category, this.existing});
  final Category category;
  final Dish? existing;

  @override
  State<DishBuilderScreen> createState() => _DishBuilderScreenState();
}

class _DishBuilderScreenState extends State<DishBuilderScreen>
    with RebuildOnTranslation {
  final _name = TextEditingController();

  /// The cook's own weight of the finished dish — optional.
  final _weighed = TextEditingController();
  late String _icon;
  late Category _category = widget.category;
  late Cooking _cooking = widget.category.usualCooking;
  final List<Ingredient> _items = [];

  bool get _isDrink => _category == Category.drinks;

  @override
  void initState() {
    super.initState();
    _icon = widget.category.icon;
    final d = widget.existing;
    if (d != null) {
      _name.text = d.name;
      _icon = d.icon;
      _items.addAll(d.ingredients.map((i) => i.copy()));
      _cooking = d.cooking ?? _category.usualCooking;
      // Dishes saved before the estimate existed carry a weighed weight.
      final estimate = Dish.theoreticalWeight(_items, _cooking);
      final w = d.finishedWeight;
      if (w != null && (d.cooking == null || (w - estimate).abs() > 0.5)) {
        _weighed.text = fmt(w);
      }
    }
  }

  void _setCategory(Category c) => setState(() {
        if (_icon == _category.icon) _icon = c.icon;
        _category = c;
        _cooking = c.usualCooking;
      });

  Product _productFor(Ingredient it) =>
      AppState.instance.allProducts.firstWhere((p) => p.name == it.name,
          orElse: () => Product(it.name, it.kcalPer100,
              protein: it.proteinPer100,
              fat: it.fatPer100,
              carbs: it.carbsPer100,
              liquid: it.liquid));

  double get _rawWeight => _items.fold(0, (s, i) => s + i.grams);
  double get _totalKcal => _items.fold(0, (s, i) => s + i.kcal);
  double get _estimate => Dish.theoreticalWeight(_items, _cooking);
  double? get _weighedValue {
    final w = parseNum(_weighed.text);
    return w != null && w > 0 ? w : null;
  }

  /// The weighed weight if the cook entered one, otherwise our estimate.
  double get _finishedWeight => _weighedValue ?? _estimate;
  double? _per(double Function(Ingredient) of) =>
      Dish.per100(_items, _finishedWeight, of);
  double? get _per100 => _per((i) => i.kcal);

  Future<void> _addIngredient() async {
    final product = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProductPicker(category: _category),
    );
    if (product == null || !mounted) return;
    final grams = await _askGrams(product);
    if (grams == null) return;
    setState(() => _items.add(Ingredient.of(product, grams)));
  }

  Future<double?> _askGrams(Product p, {double? initial}) {
    final c = TextEditingController(text: initial == null ? '' : fmt(initial));
    final tsp = p.tspGrams;
    void addSpoon(double g) {
      final now = parseNum(c.text) ?? 0;
      c.text = fmt(now + g);
    }

    return showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(p.name, style: PC.title(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumberField(
                controller: c,
                label: 'How much went in?',
                suffix: p.unit,
                autofocus: true),
            if (p.pieces.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final piece in p.pieces)
                    ActionChip(
                      label: Text(piece.hint == null
                          ? '+1 ${piece.label.toLowerCase()} (${fmt(piece.grams)} g)'
                          : '+1 ${piece.label.toLowerCase()} · ${piece.hint} (${fmt(piece.grams)} g)'),
                      onPressed: () => addSpoon(piece.grams),
                    ),
                ],
              ),
            ],
            if (tsp != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: Text('+1 tsp (${fmt(tsp)} ${p.unit})'),
                    onPressed: () => addSpoon(tsp),
                  ),
                  ActionChip(
                    label: Text('+1 tbsp (${fmt(tsp * 3)} ${p.unit})'),
                    onPressed: () => addSpoon(tsp * 3),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final g = parseNum(c.text);
              if (g != null && g > 0) Navigator.pop(ctx, g);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _save() {
    final dish = Dish(
      id: widget.existing?.id ?? AppState.newId(),
      name: _name.text.trim(),
      category: _category,
      icon: _icon,
      kcalPer100: _per100!,
      proteinPer100: _per((i) => i.protein)!,
      fatPer100: _per((i) => i.fat)!,
      carbsPer100: _per((i) => i.carbs)!,
      finishedWeight: _finishedWeight,
      cooking: _cooking,
      ingredients: List.of(_items),
    );
    AppState.instance.saveDish(dish);
    Navigator.pop(context, widget.existing == null ? dish : null);
  }

  @override
  Widget build(BuildContext context) {
    final per100 = _per100;
    final canSave = per100 != null && _name.text.trim().isNotEmpty;
    final unit = _category.unit;
    final iconChoices = [
      ..._category.icons,
      ...allDishIcons.where((i) => !_category.icons.contains(i)),
    ];

    return PCScaffold(
      title: widget.existing == null ? 'Homemade' : 'Edit dish',
      bottom: GoldButton('Save dish',
          icon: Icons.bookmark_add_outlined, onPressed: canSave ? _save : null),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          if (widget.existing == null) ...[
            Text('What are you making?',
                style: PC.body(14, color: PC.textSoft)),
            const SizedBox(height: 8),
            CategoryChoice(selected: _category, onSelect: _setCategory),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _name,
            style: PC.body(17),
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration:
                InputDecoration(labelText: t('Dish name — e.g. My borscht')),
          ),
          const SizedBox(height: 14),
          Text('Icon', style: PC.body(14, color: PC.textSoft)),
          const SizedBox(height: 6),
          SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                IconPicker(
                  icons: iconChoices,
                  selected: _icon,
                  size: 40,
                  onSelect: (i) => setState(() => _icon = i),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Text('Ingredients', style: PC.title(24))),
              if (_items.isNotEmpty)
                Text('${fmt(_rawWeight)} $unit · ${_totalKcal.round()} kcal',
                    style: PC.body(13, color: PC.textSoft)),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _items.length; i++) _ingredientRow(i),
          OutlineButtonPC('Add ingredient', onPressed: _addIngredient),
          const SizedBox(height: 24),
          Text(_isDrink ? 'Your drink' : 'How is it cooked?',
              style: PC.title(24)),
          const SizedBox(height: 8),
          if (!_isDrink) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in Cooking.values)
                  ChoiceChip(
                    label: Text(c.label),
                    selected: c == _cooking,
                    onSelected: (_) => setState(() => _cooking = c),
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Text(
            _items.isEmpty
                ? 'Add the ingredients — we\'ll estimate the finished weight.'
                : _isDrink
                    ? 'Drinks don\'t boil down: 1 ml ≈ 1 g, so your drink is about ${fmt(_estimate)} ml.'
                    : '${fmt(_rawWeight)} $unit of ingredients, ${_cooking.label.toLowerCase()} — ${_cooking.note}. Your dish weighs about ${fmt(_estimate)} $unit when done.',
            style: PC.body(13, color: PC.textSoft),
          ),
          const SizedBox(height: 10),
          NumberField(
            controller: _weighed,
            label: _isDrink
                ? 'Measured it? Your volume (optional)'
                : 'Weighed it? Your weight (optional)',
            suffix: unit,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 4),
          Text(
            _weighedValue == null
                ? 'If not, we use our estimate.'
                : 'Using your weight: ${fmt(_weighedValue!)} $unit.',
            style: PC.body(12, color: PC.textSoft),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: PC.card(border: PC.purpleLight),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              children: [
                Text(per100 == null ? '—' : fmt(per100),
                    style: PC.body(44,
                        color: PC.goldLight, weight: FontWeight.w800)),
                Text(
                    _isDrink
                        ? 'kcal per 100 ml of your drink'
                        : 'kcal per 100 g of your dish',
                    style: PC.body(14, color: PC.textSoft)),
                if (per100 != null) ...[
                  const SizedBox(height: 10),
                  MacrosRow(
                    protein: _per((i) => i.protein)!,
                    fat: _per((i) => i.fat)!,
                    carbs: _per((i) => i.carbs)!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ingredientRow(int i) {
    final it = _items[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: PC.card(border: PC.gold.withOpacity(0.3)),
        padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.name, style: PC.body(15, weight: FontWeight.w600)),
                  Text('${fmt(it.kcalPer100)} kcal / 100 ${it.unit}',
                      style: PC.body(12, color: PC.textSoft)),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                final g = await _askGrams(_productFor(it), initial: it.grams);
                if (g != null) {
                  setState(() => it.grams = g);
                }
              },
              child: Text('${fmt(it.grams)} ${it.unit}',
                  style: PC.body(15, color: PC.gold, weight: FontWeight.w600)),
            ),
            SizedBox(
              width: 70,
              child: Text('${it.kcal.round()} kcal',
                  textAlign: TextAlign.right,
                  style: PC.body(14, color: PC.goldLight)),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: PC.textSoft),
              onPressed: () => setState(() => _items.removeAt(i)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Search the built-in table + own products, or add your own.
class _ProductPicker extends StatefulWidget {
  const _ProductPicker({required this.category});
  final Category category;

  @override
  State<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<_ProductPicker>
    with RebuildOnTranslation {
  String _q = '';

  /// The search in English — typed in Ukrainian, German or French it is
  /// translated first, so "буряк" finds Beetroot.
  String _qEn = '';

  Future<void> _search(String v) async {
    setState(() => _q = v.trim());
    final en = await TranslationService.instance.toEnglish(_q);
    if (mounted && v.trim() == _q) setState(() => _qEn = en.toLowerCase());
  }

  bool _matches(Product p) {
    if (_q.isEmpty) return true;
    final name = p.name.toLowerCase();
    final shown = t(p.name).toLowerCase();
    final q = _q.toLowerCase();
    return name.contains(q) ||
        shown.contains(q) ||
        (_qEn.isNotEmpty && name.contains(_qEn));
  }

  Future<void> _addOwn() async {
    final name = TextEditingController(text: _q);
    final kcal = TextEditingController();
    final protein = TextEditingController();
    final fat = TextEditingController();
    final carbs = TextEditingController();
    final p = await showDialog<Product>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('My own product', style: PC.title(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: name,
                autofocus: true,
                decoration: InputDecoration(labelText: t('Name'))),
            const SizedBox(height: 10),
            NumberField(
                controller: kcal, label: 'kcal per 100 g (from the package)'),
            const SizedBox(height: 10),
            MacroFields(protein: protein, fat: fat, carbs: carbs),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final k = parseNum(kcal.text);
              if (name.text.trim().isEmpty || k == null) return;
              Navigator.pop(
                  ctx,
                  Product(name.text.trim(), k,
                      protein: parseNum(protein.text) ?? 0,
                      fat: parseNum(fat.text) ?? 0,
                      carbs: parseNum(carbs.text) ?? 0,
                      own: true));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (p == null) return;
    AppState.instance.addOwnProduct(p);
    if (mounted) Navigator.pop(context, p);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.category;
    final all = AppState.instance.allProducts.where(_matches);
    // My own products first, then this section's typical ones, then the rest.
    final own = all.where((p) => p.own).toList();
    final typical = all.where((p) => !p.own && p.isFor(c)).toList();
    final other = all.where((p) => !p.own && !p.isFor(c)).toList();
    final rows = <Object>[
      if (own.isNotEmpty) 'My products',
      ...own,
      if (typical.isNotEmpty) 'For ${c.label.toLowerCase()}',
      ...typical,
      if (other.isNotEmpty) 'Other products',
      ...other,
    ];

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            Text('Add ingredient', style: PC.title(26)),
            const SizedBox(height: 10),
            TextField(
              autofocus: true,
              onChanged: _search,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  labelText: t('Search products')),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addOwn,
                icon:
                    const Icon(Icons.add_circle_outline, color: PC.purpleLight),
                label: Text('Not here? Add my own product',
                    style: PC.body(14, color: PC.purpleLight)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (_, i) {
                  final row = rows[i];
                  if (row is String) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                      child: Text(row,
                          style: PC.titleItalic(17, color: PC.goldLight)),
                    );
                  }
                  final p = row as Product;
                  return ListTile(
                    dense: true,
                    title: Text(p.name, style: PC.body(15)),
                    trailing: Text('${fmt(p.kcalPer100)} kcal/100 ${p.unit}',
                        style: PC.body(13, color: PC.goldLight)),
                    onTap: () => Navigator.pop(context, p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
