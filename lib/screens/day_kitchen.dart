import 'package:flutter/material.dart' hide Text;

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'meals.dart';
import '../tr_text.dart';

const mealIcons = {
  Meal.breakfast: Icons.wb_twilight,
  Meal.lunch: Icons.wb_sunny_outlined,
  Meal.dinner: Icons.nightlight_outlined,
  Meal.snack: Icons.cookie_outlined,
};

/// My Kitchen for the selected day: the four meals and water.
/// Saved dishes live in the header book, like the calculator on home.
class DayKitchenScreen extends StatelessWidget {
  const DayKitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: PC.background),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: FillHeightColumn(
                    padding: const EdgeInsets.fromLTRB(12, 8, 20, 24),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: PC.logoGold, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              s.isToday
                                  ? 'My Kitchen'
                                  : 'My Kitchen · ${dayTitle(s.selected)}',
                              style: PC.logo(26),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const LanguageButton(size: 22, color: PC.logoGold),
                          _SavedDishesButton(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SavedDishesScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Spacer(),
                      for (final m in mealIcons.keys) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _MealPanel(meal: m),
                        ),
                        const SizedBox(height: 12),
                        const Spacer(),
                      ],
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: _WaterRow(),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A small gold book in the header — opens Saved dishes.
class _SavedDishesButton extends StatelessWidget {
  const _SavedDishesButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GoldRimIcon(Icons.menu_book_outlined, size: 44),
            const SizedBox(height: 2),
            SizedBox(
              width: 76,
              child: Text('My saved dishes',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: PC.logo(10, color: PC.logoGoldLight)),
            ),
          ],
        ),
      );
}

class _MealPanel extends StatelessWidget {
  const _MealPanel({required this.meal});
  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final items = s.entriesFor(meal);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => MealScreen(meal: meal))),
      child: Container(
        decoration: PC.sheenCard(border: PC.logoGold.withOpacity(0.7)),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            GoldRimIcon(mealIcons[meal]!),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.label, style: PC.logo(20)),
                  const SizedBox(height: 2),
                  Text(
                    items.isEmpty
                        ? 'Tap to add'
                        : items.map((e) => e.name).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PC.logo(13, color: PC.textSoft),
                  ),
                ],
              ),
            ),
            if (items.isEmpty)
              const Icon(Icons.add_circle_outline, color: PC.logoGold)
            else
              Text('${s.eatenIn(meal).round()} kcal',
                  style: PC.logo(16, color: PC.logoGoldLight)),
          ],
        ),
      ),
    );
  }
}

/// Water — a panel like the meals; tap to open the water wheel.
class _WaterRow extends StatelessWidget {
  const _WaterRow();

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final goal = s.profile?.waterMl ?? 2000;
    final ml = s.waterDay;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const WaterScreen())),
      child: Container(
        decoration: PC.sheenCard(border: PC.logoGold.withOpacity(0.7)),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            const GoldRimIcon(Icons.water_drop_outlined),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Water', style: PC.logo(20)),
                  const SizedBox(height: 2),
                  Text(ml == 0 ? 'Tap to add' : '$ml / $goal ml',
                      style: PC.logo(13, color: PC.textSoft)),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline, color: PC.logoGold),
          ],
        ),
      ),
    );
  }
}
