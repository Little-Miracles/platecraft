import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'calculator.dart';
import 'day_kitchen.dart';
import 'intro.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PCScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset('assets/logo/logo.jpg', width: 300),
            ),
            const SizedBox(height: 22),
            Text(
              'Build your kitchen once.\nKnow your calories exactly.',
              textAlign: TextAlign.center,
              style: PC.titleItalic(20, color: PC.goldLight),
            ),
            const SizedBox(height: 8),
            Text(
              'Your own dishes, from your own ingredients — not a guess.',
              textAlign: TextAlign.center,
              style: PC
                  .body(12.5, color: PC.textSoft, weight: FontWeight.w300)
                  .copyWith(fontStyle: FontStyle.italic),
            ),
            const Spacer(),
            PlateButton(
              label: 'Start',
              onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      // The golden calculator intro is for the first visit only.
                      builder: (_) => AppState.instance.profile == null
                          ? const IntroScreen()
                          : const HomeScreen())),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

/// A round "plate" in antique gold that gently breathes: tap to start.
class PlateButton extends StatefulWidget {
  const PlateButton({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<PlateButton> createState() => _PlateButtonState();
}

class _PlateButtonState extends State<PlateButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.97, end: 1.03)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 84,
          height: 84,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PC.antiqueLight, PC.antique, PC.antiqueDark],
            ),
            boxShadow: [
              BoxShadow(
                  color: PC.antique.withOpacity(0.35),
                  blurRadius: 18,
                  spreadRadius: 1),
              BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PC.emerald,
              border: Border.all(color: PC.antiqueLight, width: 1.2),
            ),
            alignment: Alignment.center,
            child: Text(widget.label,
                style: PC.titleItalic(19, color: PC.antiqueLight)),
          ),
        ),
      ),
    );
  }
}

/// The avatar is just a picture for now; the header calculator is the button.
/// Flip to true if the avatar should open something later.
const avatarTappable = false;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final p = s.profile;
        return PCScaffold(
          body: FillHeightColumn(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  Image.asset('assets/logo/icon.png', width: 40),
                  const SizedBox(width: 10),
                  const Expanded(child: PlateCraftWordmark(size: 30)),
                  // The golden calculator lives here: tap to recalculate.
                  SizedBox(
                    width: 34,
                    child: FittedBox(
                      child: GoldenCalculator(
                        display: '',
                        onTap: () => _open(context, const CalculatorScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (p != null)
                    GestureDetector(
                      onTap: avatarTappable
                          ? () => _open(context, const CalculatorScreen())
                          : null,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: PC.emeraldCard,
                        child: Icon3D(p.avatar, size: 36),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const Spacer(),
              if (!s.isToday) ...[
                Row(
                  children: [
                    Expanded(
                        child: Text(dayTitle(s.selected),
                            style: PC.logo(22, color: PC.craft))),
                    TextButton.icon(
                      onPressed: () => s.selectDay(DateTime.now()),
                      icon:
                          const Icon(Icons.today, size: 18, color: PC.logoGold),
                      label: Text('Back to today',
                          style: PC.logo(13, color: PC.logoGold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              DailyBanner(
                onSetTarget: () => _open(context, const CalculatorScreen()),
              ),
              const SizedBox(height: 6),
              const WaterDrops(),
              const SizedBox(height: 10),
              const Spacer(),
              const WeekStrip(),
              const SizedBox(height: 16),
              const Spacer(),
              KitchenPanel(
                dishes: s.dishes.length,
                onTap: () => _open(context, const DayKitchenScreen()),
              ),
              const Spacer(flex: 2),
            ],
          ),
        );
      },
    );
  }
}
