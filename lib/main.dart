import 'package:flutter/material.dart';

import 'screens/start_home.dart';
import 'state.dart';
import 'theme.dart';
import 'translation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.load();
  await TranslationService.instance.load();
  runApp(const PlateCraftApp());
}

class PlateCraftApp extends StatelessWidget {
  const PlateCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlateCraft',
      debugShowCheckedModeBanner: false,
      theme: PC.theme(),
      home: const StartScreen(),
    );
  }
}
