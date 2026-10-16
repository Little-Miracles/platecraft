import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

/// Ready-made food: a bought cupcake, a cup of café coffee — counted either
/// per 100 g/ml (from the package) or per serving ("1 cupcake = 250 kcal").
class ReadyMadeScreen extends StatefulWidget {
  const ReadyMadeScreen({super.key, required this.category, this.existing});
  final Category category;
  final Dish? existing;

  @override
  State<ReadyMadeScreen> createState() => _ReadyMadeScreenState();
}

class _ReadyMadeScreenState extends State<ReadyMadeScreen> {
  final _name = TextEditingController();
  final _kcal = TextEditingController();
  late String _icon;
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
      _icon = d.icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.category.unit;
    final k = parseNum(_kcal.text);
    final canSave = _name.text.trim().isNotEmpty && k != null;
    final iconChoices = [
      ...widget.category.icons,
      ...allDishIcons.where((i) => !widget.category.icons.contains(i)),
    ];

    return PCScaffold(
      title: widget.existing == null ? 'Ready-made' : 'Edit',
      bottom: GoldButton('Save to My Kitchen',
          icon: Icons.bookmark_add_outlined,
          onPressed: !canSave
              ? null
              : () {
                  final dish = Dish(
                    id: widget.existing?.id ?? AppState.newId(),
                    name: _name.text.trim(),
                    category: widget.category,
                    icon: _icon,
                    kcalPer100: _byServing ? 0 : k,
                    kcalPerServing: _byServing ? k : null,
                  );
                  AppState.instance.saveDish(dish);
                  Navigator.pop(context, widget.existing == null ? dish : null);
                }),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Center(child: Icon3D(_icon, size: 96)),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            style: PC.body(17),
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
                labelText: widget.category == Category.drinks
                    ? 'Name — e.g. Café cappuccino'
                    : 'Name — e.g. Bakery cupcake'),
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
          const SizedBox(height: 18),
          Text('Icon', style: PC.body(14, color: PC.textSoft)),
          const SizedBox(height: 8),
          IconPicker(
            icons: iconChoices,
            selected: _icon,
            onSelect: (i) => setState(() => _icon = i),
          ),
        ],
      ),
    );
  }
}
