import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as m show Text;
import 'package:flutter/services.dart';

import 'models.dart';
import 'state.dart';
import 'theme.dart';
import 'tr_text.dart';
import 'translation.dart';

/// A 3D icon from assets/icons/.
class Icon3D extends StatelessWidget {
  const Icon3D(this.name, {super.key, this.size = 48});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/icons/$name.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
      );
}

/// A 3D icon on a black tile, like the logo on the start screen.
/// The pictures were drawn on black: there they look deep, on emerald flat.
class IconOnBlack extends StatelessWidget {
  const IconOnBlack(this.name, {super.key, this.size = 48});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.24),
          gradient: const RadialGradient(
            center: Alignment(0, -0.35),
            radius: 0.9,
            colors: [Color(0xFF1E1E1E), Color(0xFF030303)],
          ),
          border: Border.all(color: PC.logoGold.withOpacity(0.35)),
        ),
        child: Icon3D(name, size: size * 0.82),
      );
}

/// Emerald gradient background, phone-width column centered on wide screens.
class PCScaffold extends StatelessWidget {
  const PCScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.bottom,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PC.background),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
                      child: Row(
                        children: [
                          if (Navigator.canPop(context))
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: PC.gold, size: 20),
                              onPressed: () => Navigator.pop(context),
                            )
                          else
                            const SizedBox(width: 12),
                          Expanded(
                            child: Text(title!,
                                style: PC.title(28),
                                overflow: TextOverflow.ellipsis),
                          ),
                          ...?actions,
                        ],
                      ),
                    ),
                  Expanded(child: body),
                  if (bottom != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: bottom!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GoldButton extends StatelessWidget {
  const GoldButton(this.label, {super.key, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: enabled
              ? const LinearGradient(colors: [PC.goldLight, PC.gold])
              : null,
          color: enabled ? null : Colors.white12,
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: enabled ? PC.emeraldDeep : Colors.white38),
                const SizedBox(width: 8),
              ],
              Text(label,
                  style: PC.body(17,
                      weight: FontWeight.w700,
                      color: enabled ? PC.emeraldDeep : Colors.white38)),
            ],
          ),
        ),
      ),
    );
  }
}

class OutlineButtonPC extends StatelessWidget {
  const OutlineButtonPC(this.label,
      {super.key, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 52,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.add, color: PC.gold, size: 20),
          // Shrinks instead of overflowing: three in a row, long German words.
          // (Flutter already puts the label in a Flexible.)
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label,
                style: PC.body(15, color: PC.gold, weight: FontWeight.w600)),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            side: BorderSide(color: PC.gold.withOpacity(0.7)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
}

/// Big tile with a glowing 3D icon — used for meals, categories, home buttons.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.border,
    this.gradient,
    this.glow = PC.logoGoldLight,
  });

  final String icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? border;
  final Gradient? gradient;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: PC.card(border: border, gradient: gradient),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlowIcon(icon, size: 64, glow: glow),
              const SizedBox(height: 10),
              Text(label,
                  textAlign: TextAlign.center,
                  style: PC.logo(20, color: PC.craft)),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!,
                    textAlign: TextAlign.center,
                    style: PC.logo(12.5,
                        color: PC.logoGoldLight, weight: FontWeight.w600)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 3D icon with a soft colored halo behind it.
class GlowIcon extends StatelessWidget {
  const GlowIcon(this.name,
      {super.key, this.size = 64, this.glow = PC.goldLight});
  final String name;
  final double size;
  final Color glow;

  @override
  Widget build(BuildContext context) => Container(
        width: size * 1.45,
        height: size * 1.45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            glow.withOpacity(0.35),
            glow.withOpacity(0.0),
          ]),
        ),
        child: Icon3D(name, size: size),
      );
}

/// The home banner: daily goal on the left, a golden plate that fills
/// sector by sector in the middle, eaten on the right.
class DailyBanner extends StatelessWidget {
  const DailyBanner({super.key, required this.onSetTarget});
  final VoidCallback onSetTarget;

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final p = s.profile;
    final eaten = s.eatenDay.round();

    if (p == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onSetTarget,
        child: Container(
          decoration: PC.sheenCard(border: PC.logoGold.withOpacity(0.7)),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const GlowIcon('target', size: 46, glow: PC.logoGoldLight),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set your daily goal',
                        style: PC.logo(21, color: PC.logoGoldLight)),
                    const SizedBox(height: 2),
                    Text('Eaten: $eaten kcal',
                        style: PC.logo(14, color: PC.textSoft)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: PC.logoGold),
            ],
          ),
        ),
      );
    }

    final goal = p.targetKcal;
    final progress = (eaten / goal).clamp(0.0, 1.0);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onSetTarget,
      child: Container(
        decoration: PC.sheenCard(border: PC.logoGold.withOpacity(0.7)),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _side('Daily goal', '$goal', PC.craft)),
                SizedBox(
                  width: 112,
                  height: 112,
                  child: CustomPaint(painter: PlateFillPainter(progress)),
                ),
                Expanded(child: _side('Eaten', '$eaten', PC.logoGoldLight)),
              ],
            ),
            const SizedBox(height: 8),
            MacrosRow(
                protein: s.proteinDay,
                fat: s.fatDay,
                carbs: s.carbsDay,
                size: 12),
          ],
        ),
      ),
    );
  }

  Widget _side(String label, String value, Color color) => Column(
        children: [
          Text(label, style: PC.logo(13, color: PC.textSoft)),
          const SizedBox(height: 2),
          Text(value, style: PC.logo(22, color: color)),
          Text('kcal', style: PC.logo(12, color: PC.textSoft)),
        ],
      );
}

/// A plate like the logo: two gold rim lines and 8 sectors that fill
/// with gold, clockwise from the top, as calories are eaten.
class PlateFillPainter extends CustomPainter {
  PlateFillPainter(this.progress);
  final double progress;

  static const _sectors = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = PC.logoGold;

    // Two parallel rim lines, like the Start plate.
    canvas.drawCircle(c, r - 1, rim);
    canvas.drawCircle(c, r - 7, rim);

    // The inner well where food goes.
    final inner = r - 13;
    final well = Rect.fromCircle(center: c, radius: inner);
    canvas.drawCircle(
        c, inner, Paint()..color = PC.logoGoldLight.withOpacity(0.06));

    if (progress > 0) {
      final fill = Paint()
        ..shader = const SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [PC.logoGoldDeep, PC.logoGoldLight, PC.logoGold],
          stops: [0.0, 0.6, 1.0],
        ).createShader(well);
      canvas.drawArc(well, -math.pi / 2, 2 * math.pi * progress, true, fill);
    }

    // Sector lines, like the slices on the logo plate.
    final line = Paint()
      ..strokeWidth = 1.4
      ..color = PC.emeraldDeep;
    final guide = Paint()
      ..strokeWidth = 1
      ..color = PC.logoGold.withOpacity(0.35);
    for (var i = 0; i < _sectors; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / _sectors;
      final end = c + Offset(math.cos(a), math.sin(a)) * inner;
      final filled = (i / _sectors) < progress;
      canvas.drawLine(c, end, filled ? line : guide);
    }
    canvas.drawCircle(
        c,
        inner,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = PC.logoGold.withOpacity(0.6));
  }

  @override
  bool shouldRepaint(PlateFillPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Grid of 3D icons to choose from.
class IconPicker extends StatelessWidget {
  const IconPicker(
      {super.key,
      required this.icons,
      required this.selected,
      required this.onSelect,
      this.size = 44});
  final List<String> icons;
  final String selected;
  final ValueChanged<String> onSelect;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final i in icons)
          GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: i == selected
                    ? PC.gold.withOpacity(0.18)
                    : Colors.white.withOpacity(0.04),
                border: Border.all(
                    color: i == selected ? PC.gold : Colors.transparent,
                    width: 1.5),
              ),
              child: IconOnBlack(i, size: size),
            ),
          ),
      ],
    );
  }
}

/// What kind of dish: drinks, baked goods, soups or main dishes.
class CategoryChoice extends StatelessWidget {
  const CategoryChoice(
      {super.key, required this.selected, required this.onSelect});
  final Category selected;
  final ValueChanged<Category> onSelect;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (final c in Category.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: c == selected
                        ? PC.logoGold.withOpacity(0.16)
                        : Colors.white.withOpacity(0.03),
                    border: Border.all(
                        color: c == selected
                            ? PC.logoGold
                            : PC.logoGold.withOpacity(0.2),
                        width: 1.2),
                  ),
                  child: Column(
                    children: [
                      IconOnBlack(c.icon, size: 40),
                      const SizedBox(height: 4),
                      Text(c.label.split(' ').first,
                          style: PC.logo(12,
                              color: c == selected
                                  ? PC.logoGoldLight
                                  : PC.textSoft)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
}

/// The caring evening card: how the last logged day went, with its date.
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.summary});
  final DaySummary summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    return Container(
      decoration: PC.sheenCard(border: PC.logoGold.withOpacity(0.7)),
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.nightlight_outlined,
                  color: PC.logoGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Your day · ${dayTitle(s.date)}',
                    style: PC.logo(16, color: PC.logoGoldLight)),
              ),
              IconButton(
                tooltip: t('Close'),
                icon: const Icon(Icons.close, size: 18, color: PC.textSoft),
                onPressed: () => AppState.instance.closeSummary(s),
              ),
            ],
          ),
          Text('${s.eaten.round()} of ${s.target} kcal',
              style: PC.logo(20, color: PC.craft)),
          const SizedBox(height: 4),
          Text(s.food, style: PC.logo(13.5, color: PC.textSoft)),
          const SizedBox(height: 8),
          Text(s.drink, style: PC.logo(13.5, color: PC.textSoft)),
        ],
      ),
    );
  }
}

/// Protein · fat · carbs in grams.
class MacrosRow extends StatelessWidget {
  const MacrosRow(
      {super.key,
      required this.protein,
      required this.fat,
      required this.carbs,
      this.size = 13});
  final double protein;
  final double fat;
  final double carbs;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _one('Protein', protein),
          _one('Fat', fat),
          _one('Carbs', carbs),
        ],
      );

  Widget _one(String label, double g) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Text('${g.round()} g', style: PC.logo(size + 3, color: PC.craft)),
            Text(label, style: PC.logo(size - 1, color: PC.textSoft)),
          ],
        ),
      );
}

/// Three optional fields for protein, fat and carbs from a package label.
class MacroFields extends StatelessWidget {
  const MacroFields(
      {super.key,
      required this.protein,
      required this.fat,
      required this.carbs,
      this.onChanged});
  final TextEditingController protein;
  final TextEditingController fat;
  final TextEditingController carbs;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (final (c, l) in [
            (protein, 'Protein'),
            (fat, 'Fat'),
            (carbs, 'Carbs')
          ])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: NumberField(
                    controller: c, label: l, suffix: 'g', onChanged: onChanged),
              ),
            ),
        ],
      );
}

/// Numeric text field (accepts "12.5" and "12,5").
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    this.suffix,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final String? suffix;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: TranslationService.instance.revision,
        builder: (context, _, __) => _field(),
      );

  Widget _field() => TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        style: PC.body(17),
        onChanged: onChanged,
        decoration: InputDecoration(
            labelText: t(label),
            suffixText: suffix == null ? null : t(suffix!)),
      );
}

double? parseNum(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

/// "250 g", "200 ml", "1 serving", "2 servings".
String amountLabel(double amount, String unit) {
  if (unit == 'serving') {
    return '${fmt(amount)} serving${amount == 1 ? '' : 's'}';
  }
  return '${fmt(amount)} $unit';
}

String fmt(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String dayTitle(DateTime d) {
  if (AppState.key(d) == AppState.today()) return 'Today';
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  if (AppState.key(d) == AppState.key(yesterday)) return 'Yesterday';
  return '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';
}

/// Mon–Sun strip with a mini calorie bar per day + the week's summary.
class WeekStrip extends StatefulWidget {
  const WeekStrip({super.key});

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  late DateTime _monday;
  late String _syncedDay;

  void _syncToSelected() {
    final sel = AppState.instance.selected;
    _monday = sel.subtract(Duration(days: sel.weekday - 1));
    _syncedDay = AppState.instance.day;
  }

  // The strip is const on home, so it listens itself: a new meal or water
  // must show up here right away, not on the next visit.
  void _changed() => setState(() {});

  @override
  void initState() {
    super.initState();
    _syncToSelected();
    AppState.instance.addListener(_changed);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    // A day picked elsewhere ("Back to today") brings its week into view.
    if (s.day != _syncedDay) _syncToSelected();
    final target = s.profile?.targetKcal;
    final today = AppState.dateOnly(DateTime.now());
    final days = List.generate(7, (i) => _monday.add(Duration(days: i)));
    final pastDays = days.where((d) => !d.isAfter(today)).toList();
    final logged = pastDays.where((d) => s.eatenOn(d) > 0).toList();
    final avg = logged.isEmpty
        ? 0
        : logged.fold<double>(0, (a, d) => a + s.eatenOn(d)) / logged.length;
    final onTarget =
        target == null ? 0 : logged.where((d) => s.eatenOn(d) <= target).length;
    final maxKcal = [
      target?.toDouble() ?? 0,
      ...days.map(s.eatenOn),
    ].reduce((a, b) => a > b ? a : b);
    final sunday = days.last;

    return Container(
      decoration: PC.sheenCard(border: PC.logoGold.withOpacity(0.7)),
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: PC.logoGold, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(
                    () => _monday = _monday.subtract(const Duration(days: 7))),
              ),
              Expanded(
                child: Text(
                  _monday.month == sunday.month
                      ? '${_monday.day} – ${sunday.day} '
                          '${_months[sunday.month - 1]} ${sunday.year}'
                      : '${_monday.day} ${_months[_monday.month - 1]} – '
                          '${sunday.day} ${_months[sunday.month - 1]} ${sunday.year}',
                  textAlign: TextAlign.center,
                  style:
                      PC.logo(13, color: PC.textSoft, weight: FontWeight.w400),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.chevron_right,
                    size: 20,
                    color:
                        sunday.isBefore(today) ? PC.logoGold : Colors.white24),
                onPressed: sunday.isBefore(today)
                    ? () => setState(
                        () => _monday = _monday.add(const Duration(days: 7)))
                    : null,
              ),
            ],
          ),
          Row(
            children: [
              for (final d in days)
                Expanded(child: _day(d, s, target, maxKcal, today)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            logged.isEmpty
                ? 'No meals logged this week yet'
                : target == null
                    ? 'Week average: ${avg.round()} kcal / day'
                    : 'Week average: ${avg.round()} kcal / day · '
                        '$onTarget of ${logged.length} days on target',
            style: PC.logo(12, color: PC.logoGoldLight),
          ),
        ],
      ),
    );
  }

  Widget _day(
      DateTime d, AppState s, int? target, double maxKcal, DateTime today) {
    final kcal = s.eatenOn(d);
    final future = d.isAfter(today);
    final selected = AppState.key(d) == s.day;
    final over = target != null && kcal > target;
    final h = maxKcal <= 0 ? 0.0 : (kcal / maxKcal * 40).clamp(0.0, 40.0);

    return GestureDetector(
      onTap: future ? null : () => s.selectDay(d),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? PC.logoGold.withOpacity(0.16) : Colors.transparent,
          border: Border.all(
              color: selected ? PC.logoGold : Colors.transparent, width: 1.2),
        ),
        child: Column(
          children: [
            // Eaten that day: the number over a gold column, gold like the plate.
            SizedBox(
              height: 58,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (kcal > 0)
                    Text('${kcal.round()}',
                        style: PC.logo(9,
                            color: over ? PC.purpleLight : PC.logoGoldLight)),
                  const SizedBox(height: 2),
                  Container(
                    width: 10,
                    height: h < 4 && kcal > 0 ? 4 : h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: over ? PC.purpleLight : null,
                      gradient: over ? null : PC.logoGoldGradient,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(_weekdays[d.weekday - 1].substring(0, 2),
                style:
                    PC.logo(10, color: future ? Colors.white24 : PC.textSoft)),
            Text('${d.day}',
                style: PC.logo(12,
                    weight: FontWeight.w700,
                    color: future
                        ? Colors.white24
                        : AppState.key(d) == AppState.today()
                            ? PC.logoGoldLight
                            : PC.craft)),
          ],
        ),
      ),
    );
  }
}

/// "Plate" in gold + "Craft" in white — the same lettering as the logo.
class PlateCraftWordmark extends StatelessWidget {
  const PlateCraftWordmark({super.key, this.size = 30});
  final double size;

  @override
  Widget build(BuildContext context) {
    return m.Text.rich(
      TextSpan(children: [
        TextSpan(
          text: 'Plate',
          style: PC.logo(size).copyWith(
                foreground: Paint()
                  ..shader = PC.logoGoldGradient.createShader(
                      Rect.fromLTWH(0, 0, size * 2.6, size * 1.2)),
              ),
        ),
        TextSpan(
            text: 'Craft',
            style: PC.logo(size, color: const Color(0xFFF7F3EA))),
      ]),
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Water as a row of drops — one drop per 250 ml glass, no panel around it.
class WaterDrops extends StatelessWidget {
  const WaterDrops({super.key, this.onTap, this.trailing});

  /// Null on home: the drops only show the water, they're not a button.
  final VoidCallback? onTap;

  /// Replaces the "750 / 2340 ml" text, e.g. with − / + buttons.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        // Const on home, so it listens itself for new water.
        listenable: AppState.instance,
        builder: (context, _) => _drops(),
      );

  Widget _drops() {
    final s = AppState.instance;
    final goal = s.profile?.waterMl ?? 2000;
    final ml = s.waterDay;
    final glasses = (goal / AppState.glassMl).ceil().clamp(1, 14);
    final drunk = (ml / AppState.glassMl).floor();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 2,
                children: [
                  for (var i = 0; i < glasses; i++)
                    i < drunk
                        ? const Icon3D('water', size: 22)
                        : const Opacity(
                            opacity: 0.18,
                            child: ColorFiltered(
                              // Empty glasses: grey ghosts of the drop.
                              colorFilter: ColorFilter.matrix([
                                0.33, 0.33, 0.33, 0, 0, //
                                0.33, 0.33, 0.33, 0, 0,
                                0.33, 0.33, 0.33, 0, 0,
                                0, 0, 0, 1, 0,
                              ]),
                              child: Icon3D('water', size: 22),
                            ),
                          ),
                ],
              ),
            ),
            trailing ??
                Text('$ml / $goal ml',
                    style: PC.logo(14, color: PC.craft.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}

/// Home panel for My Kitchen: the round logo plate + name, same sheen as above.
class KitchenPanel extends StatelessWidget {
  const KitchenPanel({super.key, required this.dishes, required this.onTap});
  final int dishes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: PC.sheenCard(border: PC.logoGold.withOpacity(0.7)),
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(
          children: [
            Image.asset('assets/logo/plate_emblem.png', width: 64, height: 64),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Kitchen', style: PC.logo(22)),
                  const SizedBox(height: 2),
                  Text(
                      dishes == 0
                          ? 'Your recipes live here'
                          : '$dishes dish${dishes == 1 ? '' : 'es'} saved',
                      style: PC.logo(13, color: PC.logoGoldLight)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: PC.logoGold),
          ],
        ),
      ),
    );
  }
}

/// A gold line icon inside a double gold rim — the plate style for meals.
class GoldRimIcon extends StatelessWidget {
  const GoldRimIcon(this.icon, {super.key, this.size = 52});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: PC.logoGold, width: 1.4),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: PC.logoGold.withOpacity(0.8), width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: PC.logoGoldLight, size: size * 0.46),
        ),
      );
}

/// A column that fills the screen height: [Spacer]s inside spread the
/// blocks evenly on tall screens; on short screens it simply scrolls.
class FillHeightColumn extends StatelessWidget {
  const FillHeightColumn(
      {super.key, required this.children, required this.padding});
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: box.maxHeight - padding.vertical),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      );
}
