# PlateCraft

**Build your kitchen once. Know your calories exactly.**

PlateCraft is a calorie tracker for people who cook for themselves. Instead of picking "borscht" from a generic database or letting AI guess from a photo, you build *your* dish from the real ingredients and grams you used, weigh the finished pot, and get the exact calories per 100 g of what you actually made. Save it to **My Kitchen** once — next time you just weigh your plate.

Built for Devpost **Build With AI: Basics** (October 2026), following the plan-first Devpost Learn workflow.

## What it does

- **Daily goal** — a golden calculator works out your daily calories (Mifflin–St Jeor × activity) and water (30 ml per kg).
- **Home** — a golden plate fills sector by sector as you eat; water drops; a week strip to look back at any day.
- **My Kitchen** — breakfast, lunch, dinner, snack and water for the selected day.
- **Recipes** — your library of dishes:
  - *Homemade*: ingredients in grams or ml (with teaspoon / tablespoon helpers) + finished weight → exact kcal per 100 g.
  - *Ready-made*: kcal per 100 g from the label, or per serving.
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
The screens evolved while building — see the commit history.

## Credits

- 3D food and avatar icons: [Microsoft Fluent Emoji](https://github.com/microsoft/fluentui-emoji) (MIT License).
- Calorie values: typical per-100 g values based on USDA FoodData Central.
- Fonts: Marcellus, Playfair Display, Manrope (Google Fonts, OFL).
- Logo: generated with Google Gemini and edited for the app.
