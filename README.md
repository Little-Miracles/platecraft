# PlateCraft

**Build your kitchen once. Know your calories exactly.**

PlateCraft is a calorie tracker for people who cook for themselves. Instead of picking "borscht" from a generic database or letting AI guess from a photo, you build *your* dish from the real ingredients and grams you used and get the exact calories, protein, fat and carbs per 100 g of what you actually made. No scales needed: the finished weight is estimated from how you cooked it — or enter your own. Make it once, and it waits in **Saved dishes** for next time.

Built for Devpost **Build With AI: Basics** (October 2026), following the plan-first Devpost Learn workflow.

## What it does

- **Daily goal** — a golden calculator works out your daily calories (Mifflin–St Jeor × activity) and water (30 ml per kg).
- **Home** — a golden plate fills sector by sector as you eat, with protein · fat · carbs below; water drops; a week of golden columns to look back at any day.
- **My Kitchen** — breakfast, lunch, dinner, snack and water for the selected day.
- **A meal is where you cook** — right there:
  - *Homemade*: ingredients in grams or ml (with teaspoon / tablespoon helpers) + how it's cooked → estimated finished weight (or your own) → exact kcal, protein, fat, carbs per 100 g.
  - *Ready-made*: numbers from the label, per 100 g or per serving.
  - Saving puts a usual portion into the meal (change it if yours differs) and the recipe into Saved dishes.
- **Saved dishes** — everything you've made: add it to any meal, edit it, delete it.
- **Water** — a wheel to log any amount, plus quick +500 ml / +1 L.

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
- Calorie, protein, fat and carb values: typical per-100 g values based on USDA FoodData Central (carbs without fiber, as on EU labels).
- Cooking yields: average weight-loss factors from cooking tables.
- Fonts: Marcellus, Playfair Display, Manrope (Google Fonts, OFL).
- Logo: generated with Google Gemini and edited for the app.
