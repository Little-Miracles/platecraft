import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PC {
  static const emerald = Color(0xFF0B3D2E);
  static const emeraldDeep = Color(0xFF052019);
  static const emeraldCard = Color(0xFF10513D);
  static const emeraldLight = Color(0xFF2E8B67);
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFE9C766);

  /// Logo gold — the "Plate" in the logo. Used on the home screen.
  static const logoGold = Color(0xFFC79A4B);
  static const logoGoldLight = Color(0xFFEBCB85);
  static const logoGoldDeep = Color(0xFFA67C35);
  static const logoGoldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [logoGoldLight, logoGold, logoGoldDeep],
  );

  /// SBL "Workout zone" sheen in emerald: a graphite glint in the top-left
  /// corner fading to near-black — reads as a soft pearl on the dark.
  static BoxDecoration sheenCard({Color border = Colors.white12}) =>
      BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF24423A), Color(0xFF020A07)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.2),
      );
  static const purple = Color(0xFF7E3FBF);
  static const purpleLight = Color(0xFFB07FE6);
  static const antique = Color(0xFFB08D3C);
  static const antiqueLight = Color(0xFFD9BC72);
  static const antiqueDark = Color(0xFF7A5E22);
  static const text = Colors.white;
  static const textSoft = Color(0xFFB9D3C8);

  /// Deep emerald with a soft glow at the top.
  static const background = RadialGradient(
    center: Alignment(0, -1.1),
    radius: 1.4,
    colors: [Color(0xFF1B6B50), Color(0xFF0A3527), Color(0xFF03150F)],
    stops: [0.0, 0.45, 1.0],
  );

  /// Banner: purple shimmer into emerald.
  static const bannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A1D66), Color(0xFF1C2F4A), Color(0xFF0E3B2D)],
  );

  static const purpleTile = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4B2585), Color(0xFF221040)],
  );

  static const emeraldTile = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F7A5A), Color(0xFF0B3A2B)],
  );

  static TextStyle title(double size, {Color color = gold}) =>
      GoogleFonts.playfairDisplay(
          fontSize: size, fontWeight: FontWeight.w700, color: color);

  static TextStyle titleItalic(double size, {Color color = gold}) =>
      GoogleFonts.playfairDisplay(
          fontSize: size,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          color: color);

  /// The logo's lettering: flared serif, like "PlateCraft" on the logo.
  /// Warm white of "Craft" in the logo.
  static const craft = Color(0xFFF7F3EA);

  /// Logo lettering (Marcellus has one weight, so [weight] only hints intent).
  static TextStyle logo(double size,
          {Color color = craft, FontWeight? weight}) =>
      GoogleFonts.marcellus(fontSize: size, color: color, letterSpacing: 0.3);

  static TextStyle body(double size,
          {Color color = text, FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.manrope(fontSize: size, color: color, fontWeight: weight);

  static BoxDecoration card({Color? border, Color? fill, Gradient? gradient}) =>
      BoxDecoration(
        color:
            gradient == null ? (fill ?? emeraldCard.withOpacity(0.55)) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: (border ?? gold).withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      );

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emerald,
        brightness: Brightness.dark,
        primary: gold,
        secondary: purpleLight,
        surface: emeraldCard,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: emeraldDeep,
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: emeraldDeep.withOpacity(0.6),
        labelStyle: const TextStyle(color: textSoft),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: gold.withOpacity(0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: emerald,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: emerald,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: gold.withOpacity(0.5)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: purple,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
