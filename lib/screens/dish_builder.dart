import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

/// Homemade dish: ingredients in grams + the weight of the finished dish
/// → exact kcal per 100 g. Saved to My Kitchen.
class DishBuilderScreen extends StatefulWidget {
  const DishBuilderScreen({super.key, required this.category, this.existing});
  final Category category;
  final Dish? existing;

  @override
  State<DishBuilderScreen> createState() => _DishBuilderScreenState();
}

class _DishBuilderScreenState extends State<DishBuilderScreen> {
  final _name = TextEditingController();
  final _finished = TextEditingController();
  late String _icon;
  final List<Ingredient> _items = [];

  /// For drinks the finished volume follows the ingredients until edited.
  bool _finishedTouched = false;
  bool get _isDrink => widget.category == Category.drinks;

  @override
  void initState() {
    super.initState();
    _icon = widget.category.icon;
    final d = widget.existing;
    if (d != null) {
      _name.text = d.name;
      _icon = d.icon;
      _finished.text = d.finishedWeight == null ? '' : fmt(d.finishedWeight!);
      _items.addAll(d.ingredients.map(
          (i) => Ingredient(i.name, i.grams, i.kcalPer100, liquid: i.liquid)));
      _finishedTouched = true;
    }
  }

  void _itemsChanged() {
    if (_isDrink && !_finishedTouched) {
      _finished.text = _items.isEmpty ? '' : fmt(_rawWeight);
    }
  }

  Product _productFor(Ingredient it) =>
      AppState.instance.allProducts.firstWhere((p) => p.name == it.name,
          orElse: () => Product(it.name, it.kcalPer100, liquid: it.liquid));

  double get _rawWeight => _items.fold(0, (s, i) => s + i.grams);
  double get _totalKcal => _items.fold(0, (s, i) => s + i.kcal);
  double? get _per100 => Dish.per100(_items, parseNum(_finished.text) ?? 0);

  Future<void> _addIngredient() async {
    final product = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProductPicker(category: widget.category),
    );
    if (product == null || !mounted) return;
    final grams = await _askGrams(product);
    if (grams == null) return;
    setState(() {
      _items.add(Ingredient(product.name, grams, product.kcalPer100,
          liquid: product.liquid));
      _itemsChanged();
    });
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
    final finished = parseNum(_finished.text)!;
    final dish = Dish(
      id: widget.existing?.id ?? AppState.newId(),
      name: _name.text.trim(),
      category: widget.category,
      icon: _icon,
      kcalPer100: _per100!,
      finishedWeight: finished,
      ingredients: List.of(_items),
    );
    AppState.instance.saveDish(dish);
    Navigator.pop(context, widget.existing == null ? dish : null);
  }

  @override
  Widget build(BuildContext context) {
    final per100 = _per100;
    final canSave = per100 != null && _name.text.trim().isNotEmpty;
    final iconChoices = [
      ...widget.category.icons,
      ...allDishIcons.where((i) => !widget.category.icons.contains(i)),
    ];

    return PCScaffold(
      title: widget.existing == null ? 'Homemade' : 'Edit dish',
      bottom: GoldButton('Save to My Kitchen',
          icon: Icons.bookmark_add_outlined, onPressed: canSave ? _save : null),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          TextField(
            controller: _name,
            style: PC.body(17),
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration:
                const InputDecoration(labelText: 'Dish name — e.g. My borscht'),
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
                Text(
                    '${fmt(_rawWeight)} ${widget.category.unit} · ${_totalKcal.round()} kcal',
                    style: PC.body(13, color: PC.textSoft)),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _items.length; i++) _ingredientRow(i),
          OutlineButtonPC('Add ingredient', onPressed: _addIngredient),
          const SizedBox(height: 24),
          Text(
              widget.category == Category.drinks
                  ? 'Measure the finished drink'
                  : 'Weigh the finished dish',
              style: PC.title(24)),
          const SizedBox(height: 4),
          Text(
            _isDrink
                ? 'Filled in from your ingredients — change it if your cup holds a different amount.'
                : 'Water boils off, pasta soaks it up — the pot\'s real weight is what makes this exact.',
            style: PC.body(13, color: PC.textSoft),
          ),
          const SizedBox(height: 10),
          NumberField(
            controller: _finished,
            label: widget.category == Category.drinks
                ? 'Finished volume'
                : 'Finished weight',
            suffix: widget.category.unit,
            onChanged: (_) => setState(() => _finishedTouched = true),
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
                    widget.category == Category.drinks
                        ? 'kcal per 100 ml of your drink'
                        : 'kcal per 100 g of your dish',
                    style: PC.body(14, color: PC.textSoft)),
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
                  setState(() {
                    it.grams = g;
                    _itemsChanged();
                  });
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
              onPressed: () => setState(() {
                _items.removeAt(i);
                _itemsChanged();
              }),
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

class _ProductPickerState extends State<_ProductPicker> {
  String _q = '';

  Future<void> _addOwn() async {
    final name = TextEditingController(text: _q);
    final kcal = TextEditingController();
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
                decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 10),
            NumberField(
                controller: kcal, label: 'kcal per 100 g (from the package)'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final k = parseNum(kcal.text);
              if (name.text.trim().isEmpty || k == null) return;
              Navigator.pop(ctx, Product(name.text.trim(), k, own: true));
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
    final all = AppState.instance.allProducts.where(
        (p) => _q.isEmpty || p.name.toLowerCase().contains(_q.toLowerCase()));
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
              onChanged: (v) => setState(() => _q = v.trim()),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search), labelText: 'Search products'),
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
