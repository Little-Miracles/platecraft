# PlateCraft

**Build your kitchen once. Know your calories exactly.**

PlateCraft is a calorie tracker for people who cook for themselves. Instead of picking "borscht" from a generic database or letting AI guess from a photo, you build *your* dish from the real ingredients and grams you used and get the exact calories, protein, fat and carbs per 100 g of what you actually made. No scales needed: the finished weight is estimated from how you cooked it — or enter your own. Make it once, and it waits in **Saved dishes** for next time.

Built for Devpost **Build With AI: Basics** (October 2026), following the plan-first Devpost Learn workflow.

## What it does

- **Daily goal** — a golden calculator works out your daily calories (Mifflin–St Jeor × activity) for your goal — health, losing (−15%) or gaining (+10%) weight — and water (30 ml per kg).
- **Home** — a golden plate fills sector by sector as you eat, with protein · fat · carbs below; water drops; a week of golden columns to look back at any day.
- **A caring evening card** — from 20:30 (or the next time you open the app) a soft summary of the day, read by your goal; water always with "check with your dietitian".
- **My Kitchen** — breakfast, lunch, dinner, snack and water for the selected day. Three ways into a meal:
  - *Product*: food eaten as it is (sour cream, an apple) — grams, spoons or a size by eye (+1 medium egg).
  - *Homemade*: ingredients + how it's cooked → estimated finished weight (or your own) → exact kcal, protein, fat, carbs per 100 g.
  - *Ready-made*: numbers from the label, per 100 g or per serving.
- **My saved dishes** — everything you've made: add it to any meal, edit it, delete it.
- **Water** — a wheel to log any amount, plus quick +500 ml / +1 L.
- **Language globe** — English, Ukrainian, German, French, translated on the fly (no translation files inside); product search works in your language.
- **Backup** — save all your data to one file and restore it on a new phone.

Everything is stored in the browser. No accounts, no server, no AI keys.

## Run it

Requires Flutter 3.13 (Dart 3.1).

```bash
flutter pub get
flutter run -d chrome
```

Use Chrome DevTools device mode for a phone-sized view.

## How it was planned

The planning documents written during the hackathon are in [`devpost/`](devpost/):
[scope](devpost/scope.md) · [PRD](devpost/prd.md) · [spec](devpost/spec.md).
The screens evolved while building — every change and the reason for it is in the [build log](devpost/build-log.md), and in the commit history.

## Credits

- 3D food and avatar icons: [Microsoft Fluent Emoji](https://github.com/microsoft/fluentui-emoji) (MIT License).
- The beetroot (Fluent Emoji has none) was drawn for the app in the same style — `tool/draw_beetroot.py`.
- Calorie, protein, fat and carb values: typical per-100 g values based on USDA FoodData Central (carbs without fiber, as on EU labels).
- Cooking yields: average weight-loss factors from cooking tables.
- Fonts: Marcellus, Playfair Display, Manrope (Google Fonts, OFL).
- Logo: generated with Google Gemini and edited for the app.

## License

The PlateCraft code is released under the [Apache License 2.0](LICENSE).
Third-party assets keep their own licenses (see Credits above).
