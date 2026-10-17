import 'dart:convert';

import 'package:flutter/material.dart' hide Text;

import '../backup_io.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import '../tr_text.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  void _say(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _saveBackup() async {
    final s = AppState.instance;
    final name = s.backupFileName();
    await downloadText(
        name, const JsonEncoder.withIndent(' ').convert(s.backup()));
    if (mounted) _say('Backup saved: $name');
  }

  Future<void> _restore() async {
    final text = await pickTextFile();
    if (text == null) return;
    if (!mounted) return;
    Map<String, dynamic> j;
    try {
      j = jsonDecode(text) as Map<String, dynamic>;
      if (j['app'] != 'PlateCraft') throw const FormatException();
    } catch (_) {
      _say('This file is not a PlateCraft backup.');
      return;
    }
    final saved = DateTime.tryParse(j['saved'] as String? ?? '');
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restore the backup?', style: PC.title(22)),
        content: Text(
            saved == null
                ? 'Your current data will be replaced by the file.'
                : 'Your current data will be replaced by the backup from ${dayTitle(saved)} ${saved.year}.',
            style: PC.body(14, color: PC.textSoft)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Restore')),
        ],
      ),
    );
    if (yes != true) return;
    if (!mounted) return;
    try {
      AppState.instance.restore(j);
    } catch (_) {
      _say('This file is damaged — nothing was changed.');
      return;
    }
    _say('Your data is back.');
    Navigator.pop(context);
  }

  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  bool _female = true;
  double _activity = activities[1].factor;
  String _avatar = avatarIcons.first;
  Goal _goal = Goal.health;

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
      _goal = p.goal;
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
        avatar: _avatar,
        goal: _goal);
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
          Text('What are you counting for?',
              style: PC.body(14, color: PC.textSoft)),
          const SizedBox(height: 8),
          SegmentedButton<Goal>(
            segments: [
              for (final g in Goal.values)
                ButtonSegment(value: g, label: Text(g.label)),
            ],
            selected: {_goal},
            onSelectionChanged: (v) => setState(() => _goal = v.first),
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
            'Mifflin–St Jeor formula × activity; −15% to lose weight, +10% to gain. Water: 30 ml per kg.',
            textAlign: TextAlign.center,
            style: PC.body(12, color: PC.textSoft),
          ),
          const SizedBox(height: 28),
          Text('Your data', style: PC.title(22)),
          const SizedBox(height: 4),
          Text(
            'Everything stays in this browser. Save a backup file to keep it safe or to move it to a new phone.',
            style: PC.body(13, color: PC.textSoft),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlineButtonPC('Save a backup',
                    icon: Icons.download_outlined, onPressed: _saveBackup),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlineButtonPC('Restore',
                    icon: Icons.upload_file_outlined, onPressed: _restore),
              ),
            ],
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
