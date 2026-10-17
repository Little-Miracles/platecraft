import 'package:flutter/material.dart' hide Text;

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import '../tr_text.dart';
import '../translation.dart';

/// Ready-made food: a bought cupcake, a cup of café coffee — counted either
/// per 100 g/ml (from the package) or per serving ("1 cupcake = 250 kcal").
class ReadyMadeScreen extends StatefulWidget {
  const ReadyMadeScreen({super.key, required this.category, this.existing});
  final Category category;
  final Dish? existing;

  @override
  State<ReadyMadeScreen> createState() => _ReadyMadeScreenState();
}

class _ReadyMadeScreenState extends State<ReadyMadeScreen>
    with RebuildOnTranslation {
  final _name = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _fat = TextEditingController();
  final _carbs = TextEditingController();
  late String _icon;
  late Category _category = widget.category;
  bool _byServing = false;

  @override
  void initState() {
    super.initState();
    _icon = widget.category.icon;
    final d = widget.existing;
    if (d != null) {
      _name.text = d.name;
      _byServing = d.byServing;
      _kcal.text = fmt(d.kcalPerServing ?? d.kcalPer100);
      for (final (c, v) in [
        (_protein, d.proteinPer100),
        (_fat, d.fatPer100),
        (_carbs, d.carbsPer100)
      ]) {
        if (v > 0) c.text = fmt(v);
      }
      _icon = d.icon;
    }
  }

  void _setCategory(Category c) => setState(() {
        if (_icon == _category.icon) _icon = c.icon;
        _category = c;
      });

  @override
  Widget build(BuildContext context) {
    final unit = _category.unit;
    final k = parseNum(_kcal.text);
    final canSave = _name.text.trim().isNotEmpty && k != null;
    final iconChoices = [
      ..._category.icons,
      ...allDishIcons.where((i) => !_category.icons.contains(i)),
    ];

    return PCScaffold(
      title: widget.existing == null ? 'Ready-made' : 'Edit',
      bottom: GoldButton('Save dish',
          icon: Icons.bookmark_add_outlined,
          onPressed: !canSave
              ? null
              : () {
                  final dish = Dish(
                    id: widget.existing?.id ?? AppState.newId(),
                    name: _name.text.trim(),
                    category: _category,
                    icon: _icon,
                    kcalPer100: _byServing ? 0 : k,
                    proteinPer100: parseNum(_protein.text) ?? 0,
                    fatPer100: parseNum(_fat.text) ?? 0,
                    carbsPer100: parseNum(_carbs.text) ?? 0,
                    kcalPerServing: _byServing ? k : null,
                  );
                  AppState.instance.saveDish(dish);
                  Navigator.pop(context, widget.existing == null ? dish : null);
                }),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          if (widget.existing == null) ...[
            Text('What is it?', style: PC.body(14, color: PC.textSoft)),
            const SizedBox(height: 8),
            CategoryChoice(selected: _category, onSelect: _setCategory),
            const SizedBox(height: 16),
          ],
          Center(child: IconOnBlack(_icon, size: 110)),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            style: PC.body(17),
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
                labelText: t(_category == Category.drinks
                    ? 'Name — e.g. Café cappuccino'
                    : 'Name — e.g. Bakery cupcake')),
          ),
          const SizedBox(height: 14),
          Text('Icon', style: PC.body(14, color: PC.textSoft)),
          const SizedBox(height: 8),
          // One scrolling row, like in Homemade — the fields stay in view.
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
          const SizedBox(height: 16),
          Text('How is it counted?', style: PC.body(14, color: PC.textSoft)),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text('Per 100 $unit')),
              const ButtonSegment(value: true, label: Text('Per serving')),
            ],
            selected: {_byServing},
            onSelectionChanged: (v) => setState(() => _byServing = v.first),
          ),
          const SizedBox(height: 6),
          Text(
            _byServing
                ? 'One cup, one cupcake, one portion — kcal for the whole thing.'
                : 'Use the number from the package label.',
            style: PC.body(12, color: PC.textSoft),
          ),
          const SizedBox(height: 12),
          NumberField(
            controller: _kcal,
            label: _byServing ? 'kcal in one serving' : 'kcal per 100 $unit',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text(
              _byServing
                  ? 'Protein, fat, carbs in one serving (optional)'
                  : 'Protein, fat, carbs per 100 $unit (optional)',
              style: PC.body(12, color: PC.textSoft)),
          const SizedBox(height: 6),
          MacroFields(protein: _protein, fat: _fat, carbs: _carbs),
        ],
      ),
    );
  }
}
