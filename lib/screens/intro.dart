import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import 'calculator.dart';
import 'start_home.dart';

/// Between Start and Home: a typewriter line invites you to find your daily
/// goal, then a golden calculator appears and gently wiggles — tap it.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  static const _invite =
      "First, let's find your daily calories — from your height, weight, age and activity.";

  String _full = '';
  String _shown = '';
  int _passes = 1;
  Timer? _timer;
  bool _calcVisible = false;
  bool _done = false; // goal is calculated → show result + Continue

  @override
  void initState() {
    super.initState();
    final p = AppState.instance.profile;
    if (p == null) {
      _type(_invite);
    } else {
      _showResult(welcomeBack: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Types [text] letter by letter; repeats [passes] times, the last one stays.
  void _type(String text, {int passes = 1, VoidCallback? onDone}) {
    _timer?.cancel();
    _full = text;
    _passes = passes;
    var i = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 42), (t) {
      if (i < _full.length) {
        setState(() => _shown = _full.substring(0, ++i));
        return;
      }
      t.cancel();
      _passes--;
      if (_passes > 0) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() => _shown = '');
          _type(_full, passes: _passes, onDone: onDone);
        });
      } else {
        setState(() => _calcVisible = true);
        onDone?.call();
      }
    });
  }

  void _showResult({bool welcomeBack = false}) {
    final kcal = AppState.instance.profile!.targetKcal;
    setState(() {
      _done = false;
      _shown = '';
    });
    _type(
      welcomeBack
          ? 'Welcome back. Your daily goal is $kcal kcal.'
          : 'Done! Your daily goal is $kcal kcal. The calculator stays with you — recalculate anytime your weight or activity changes.',
      onDone: () => setState(() => _done = true),
    );
  }

  Future<void> _openCalculator() async {
    final before = AppState.instance.profile;
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const CalculatorScreen()));
    if (!mounted) return;
    if (AppState.instance.profile != null &&
        AppState.instance.profile != before) {
      _showResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppState.instance.profile;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PC.background),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 56),
                    SizedBox(
                      height: 132,
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(text: _shown),
                          if (_shown.length < _full.length)
                            const TextSpan(
                                text: '|',
                                style: TextStyle(color: PC.antiqueDark)),
                        ]),
                        textAlign: TextAlign.center,
                        style:
                            PC.titleItalic(22, color: PC.antiqueLight).copyWith(
                                  height: 1.4,
                                ),
                      ),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: _calcVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 700),
                      child: AnimatedScale(
                        scale: _calcVisible ? 1 : 0.85,
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutBack,
                        child: IgnorePointer(
                          ignoring: !_calcVisible,
                          child: GoldenCalculator(
                            display: p == null ? '' : '${p.targetKcal}',
                            onTap: _openCalculator,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedOpacity(
                      opacity: _calcVisible && p == null ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      child: Text('Tap the calculator',
                          style: PC.body(13, color: PC.textSoft)),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: _done ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      child: IgnorePointer(
                        ignoring: !_done,
                        child: PearlButton(
                          'Continue',
                          onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen())),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A calculator made of antique gold: dark display, rows of keys.
/// It gives a small wiggle every couple of seconds to invite a tap.
class GoldenCalculator extends StatefulWidget {
  const GoldenCalculator(
      {super.key,
      required this.display,
      required this.onTap,
      this.wiggle = true});
  final String display;
  final VoidCallback onTap;

  /// The small header version stays still.
  final bool wiggle;

  @override
  State<GoldenCalculator> createState() => _GoldenCalculatorState();
}

class _GoldenCalculatorState extends State<GoldenCalculator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static const _keys = [
    '7', '8', '9', '÷', //
    '4', '5', '6', '×',
    '1', '2', '3', '−',
    '0', '.', '=', '+',
  ];

  Widget _key(String k) => Container(
        width: 31,
        height: 31,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: k == '='
                ? const [PC.emeraldLight, PC.emerald]
                : [
                    Colors.white.withOpacity(0.35),
                    PC.antique.withOpacity(0.6),
                  ],
          ),
          border: Border.all(color: PC.antiqueDark.withOpacity(0.6)),
        ),
        child: Text(k,
            style: PC.body(14,
                color: k == '=' ? PC.antiqueLight : PC.emeraldDeep,
                weight: FontWeight.w800)),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Wiggle only during the first 18% of each cycle, rest is still.
        final t = _c.value;
        final angle = widget.wiggle && t < 0.18
            ? math.sin(t / 0.18 * math.pi * 4) * 0.045
            : 0.0;
        return Transform.rotate(angle: angle, child: child);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 176,
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PC.antiqueLight, PC.antique, PC.antiqueDark],
            ),
            boxShadow: [
              BoxShadow(
                  color: PC.antique.withOpacity(0.35),
                  blurRadius: 30,
                  spreadRadius: 2),
              BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 48,
                width: double.infinity,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: PC.emeraldDeep,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PC.antiqueDark, width: 1.5),
                ),
                child: Text(
                  widget.display.isEmpty ? 'kcal ?' : '${widget.display} kcal',
                  style: PC.body(20,
                      color: PC.antiqueLight, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              // Plain rows (not a grid) so the calculator can report its
              // height when it sits in the home header.
              for (var r = 0; r < 4; r++) ...[
                if (r > 0) const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final k in _keys.sublist(r * 4, r * 4 + 4)) _key(k),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Pearlescent violet button — a soft shimmer from deep violet to lavender.
class PearlButton extends StatelessWidget {
  const PearlButton(this.label, {super.key, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A1F73),
              Color(0xFF8E5CC9),
              Color(0xFFD6C2F2),
              Color(0xFF9A6AD6),
              Color(0xFF5B2A86),
            ],
            stops: [0.0, 0.35, 0.5, 0.65, 1.0],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
                color: PC.purple.withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Stack(
          children: [
            // Pearl sheen on the upper half.
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(27),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: FractionallySizedBox(
                    heightFactor: 0.5,
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.28),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(label,
                  style: PC.titleItalic(21, color: Colors.white).copyWith(
                    shadows: [
                      Shadow(
                          color: Colors.black.withOpacity(0.35), blurRadius: 4),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
