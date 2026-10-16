import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  bool _female = true;
  double _activity = activities[1].factor;
  String _avatar = avatarIcons.first;

  @override
  void initState() {
    super.initState();
    final p = AppState.instance.profile;
    if (p != null) {
      _female = p.female;
      _age.text = '${p.age}';
      _height.text = fmt(p.heightCm);
      _weight.text = fmt(p.weightKg);
      _activity = p.activity;
      _avatar = p.avatar;
    }
  }

  Profile? get _draft {
    final age = int.tryParse(_age.text.trim());
    final h = parseNum(_height.text);
    final w = parseNum(_weight.text);
    if (age == null || h == null || w == null) return null;
    if (age < 10 || age > 110 || h < 100 || h > 250 || w < 30 || w > 300) {
      return null;
    }
    return Profile(
        female: _female,
        age: age,
        heightCm: h,
        weightKg: w,
        activity: _activity,
        avatar: _avatar);
  }

  @override
  Widget build(BuildContext context) {
    final d = _draft;
    return PCScaffold(
      title: 'Calculator',
      bottom: GoldButton('Save my target',
          icon: Icons.check,
          onPressed: d == null
              ? null
              : () {
                  AppState.instance.saveProfile(d);
                  Navigator.pop(context);
                }),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Text('Choose your avatar', style: PC.body(14, color: PC.textSoft)),
          const SizedBox(height: 8),
          IconPicker(
              icons: avatarIcons,
              selected: _avatar,
              onSelect: (a) => setState(() => _avatar = a)),
          const SizedBox(height: 20),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Female')),
              ButtonSegment(value: false, label: Text('Male')),
            ],
            selected: {_female},
            onSelectionChanged: (v) => setState(() => _female = v.first),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: NumberField(
                      controller: _age,
                      label: 'Age',
                      suffix: 'years',
                      onChanged: (_) => setState(() {}))),
              const SizedBox(width: 10),
              Expanded(
                  child: NumberField(
                      controller: _height,
                      label: 'Height',
                      suffix: 'cm',
                      onChanged: (_) => setState(() {}))),
              const SizedBox(width: 10),
              Expanded(
                  child: NumberField(
                      controller: _weight,
                      label: 'Weight',
                      suffix: 'kg',
                      onChanged: (_) => setState(() {}))),
            ],
          ),
          const SizedBox(height: 16),
          Text('Activity', style: PC.body(14, color: PC.textSoft)),
          const SizedBox(height: 6),
          for (final a in activities)
            RadioListTile<double>(
              value: a.factor,
              groupValue: _activity,
              activeColor: PC.gold,
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(a.label, style: PC.body(14)),
              onChanged: (v) => setState(() => _activity = v!),
            ),
          const SizedBox(height: 12),
          Container(
            decoration: PC.card(),
            padding: const EdgeInsets.all(18),
            child: d == null
                ? Text('Fill in age, height and weight to see your target.',
                    textAlign: TextAlign.center,
                    style: PC.body(14, color: PC.textSoft))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _result('calculator', '${d.targetKcal}', 'kcal / day'),
                      _result('water', '${d.waterMl}', 'ml water / day'),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mifflin–St Jeor formula × activity. Water: 30 ml per kg.',
            textAlign: TextAlign.center,
            style: PC.body(12, color: PC.textSoft),
          ),
        ],
      ),
    );
  }

  Widget _result(String icon, String value, String label) => Column(
        children: [
          Icon3D(icon, size: 40),
          const SizedBox(height: 6),
          Text(value,
              style: PC.body(28, color: PC.goldLight, weight: FontWeight.w700)),
          Text(label, style: PC.body(12, color: PC.textSoft)),
        ],
      );
}
