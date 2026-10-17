---
doc: spec
status: draft (updated 17.10 — two flows, estimated weight, macros; see build-log.md)
---

# PlateCraft — Technical Spec

## How This Works, In Plain Language
PlateCraft is one Flutter app that runs in the browser. It has three pieces:
- **Screens** — what you see and tap (start, home, calculator, meals, dish builder…).
- **The kitchen brain** (`AppState`) — holds your profile, your saved dishes, your own products and what you ate today; it does the math (daily target, kcal per 100 g, portion kcal) and tells the screens to refresh.
- **The browser's memory** (`shared_preferences`, which uses the browser's localStorage) — the brain writes everything there, so a page reload doesn't lose your kitchen.
The product table is a small JSON file shipped with the app. No server, no AI, no keys — the repository is public and nothing secret is needed. This is the smallest shape that proves the kernel: exact numbers from your own ingredients.

## The Core Journey Through the System
PRD ref: `prd.md > The Core Journey`.
1. Start → Home reads `AppState.profile` and today's entries → banner shows target / eaten / water.
2. Calculator → user enters data → `AppState.saveProfile()` computes BMR × activity and water → saved → banner updates.
3. My Kitchen → Meal (e.g. lunch) → **Homemade** (or Ready-made).
4. Dish builder: user picks the kind (soup), searches products (`assets/data/products.json` + own products), adds grams → picks how it's cooked → builder estimates `finishedWeight = Σ grams × Cooking.yieldFactor` (or uses the weight the user typed) and shows `per 100 g = Σ(grams × value/100) ÷ finishedWeight × 100` live for kcal, protein, fat and carbs → Save → `AppState.saveDish()` stores it in Saved dishes.
5. Portion sheet opens at `Dish.standardPortion` (bowl 300 g) → `AppState.addEntry(meal, dish, grams)` → entry with kcal + macros stored for the selected day → Home banner, week strip and drops update at once.
6. Next day → Saved dishes (or "From Saved dishes" on a meal) → tap the borscht → choose the meal → portion sheet → add.

## Stack
- **Flutter 3.13.9 / Dart 3.1** (already installed on the learner's Mac, runs on macOS 12) — web target. https://docs.flutter.dev
- **shared_preferences** — browser storage. https://pub.dev/packages/shared_preferences
- **google_fonts** — serif headings like the logo (Cormorant Garamond) + clean body (Inter). https://pub.dev/packages/google_fonts
- **Fluent Emoji 3D** (Microsoft, MIT license) — volumetric icons, bundled as PNG in `assets/icons/`. https://github.com/microsoft/fluentui-emoji
- State: Flutter's built-in `ChangeNotifier` + `ListenableBuilder` — no extra state library.
Choice of Flutter: the learner's apps are Flutter, and the builder moves into Smart Body Life later.

## Where It Runs and How Someone Tries It
- Run locally: `flutter run -d chrome` in the project folder; use Chrome DevTools device mode (phone size) for the demo recording (Cmd+Shift+5).
- No API keys. Deployment (e.g. GitHub Pages) optional, decided at `6-ship`.

## Look and Feel
From `prd.md > Look and Feel`: deep emerald background (#0B3D2E → #062A20 gradient), gold accents (#D4AF37 / #E9C766), purple highlights (#7E3FBF / #9B59D0), white text. Serif headings (Cormorant Garamond) echoing the logo's "PlateCraft"; Inter for body and numbers. Rounded cards with a thin gold border, generous spacing, calm. Big 3D icons on tiles. Interface copy: short, warm, English. Phone-width layout centered on desktop (max width ~480 px).

## Components

### Start screen — `prd.md > Screens and Layout`
Logo image + Start → Home.

### Home + banner — `prd.md > The Core Journey`
Banner: target, eaten, remaining, water progress; avatar. Buttons: Calculator, My Kitchen. Today's meals summary.

### Calculator — `prd.md > Daily calculator`
Form (sex, age, height cm, weight kg, activity level 1.2–1.9) + avatar picker; Mifflin–St Jeor; water = 30 ml × kg.

### Meals / Meal / Category screens — `prd.md > Screens and Layout`
Tiles with 3D icons; category lists saved dishes of that category + "Ready-made" + "Homemade".

### Dish builder — `prd.md > My Kitchen (dish builder + library)`
Ingredient rows (product, grams, kcal), product search sheet, "add my own product", finished weight field, live kcal/100 g, name + icon picker, Save.

### Ready-made form — `prd.md > Ready-made food`
Name, kcal/100 g, icon; saved to My Kitchen as a dish without ingredients.

### Portion sheet — `prd.md > The Core Journey`
Grams eaten → portion kcal → Add to meal.

### Water — `prd.md > Water`
+250 ml glass; −1 to undo.

## Data Model
All stored as JSON strings in shared_preferences (browser localStorage):
- `profile`: {sex, age, heightCm, weightKg, activity, avatar} → derived targetKcal, waterMl.
- `dishes`: [{id, name, category, icon, kcalPer100, finishedWeight?, ingredients: [{productName, grams, kcalPer100}]}]
- `ownProducts`: [{name, kcalPer100}]
- `entries`: [{date: "YYYY-MM-DD", meal, dishId, dishName, icon, grams, kcal}]
- `water`: {date, ml}
Built-in products: `assets/data/products.json` [{name, kcalPer100}] — read-only.
Leaving and coming back: everything reloads from storage; entries from earlier days are kept but Home shows only today.

## File Structure
```
platecraft/
├── lib/
│   ├── main.dart            # app, theme, routes
│   ├── theme.dart           # colors, fonts, card styles
│   ├── state.dart           # AppState: data, math, storage
│   ├── models.dart          # Profile, Dish, Ingredient, Product, Entry
│   ├── widgets.dart         # shared tiles, banner, icon picker
│   └── screens/             # start, home, calculator, meals, meal, category,
│                            # dish_builder, ready_made, portion sheet, water
├── assets/
│   ├── logo/                # PlateCraft logo + icon
│   ├── icons/               # Fluent Emoji 3D PNGs (MIT)
│   └── data/products.json   # built-in product table
├── web/                     # favicon, index.html
├── devpost/                 # Devpost learning workspace
└── README.md
```

## External Services and Dependencies
None at runtime. Google Fonts are fetched by the browser from fonts.googleapis.com (free, no key); if offline, Flutter falls back to the default font.

## Important Failure Modes
- **Finished weight missing or 0** → kcal/100 g shows "—", Save disabled.
- **Browser storage cleared / private window** → app starts fresh like a first visit.
- **Product not in the table** → "Add my own product" with kcal from the package.

## What Was Simplified and Why
- **Browser storage** instead of accounts/cloud — one person's prototype; cloud would need login and a backend.
- **Built-in 3D icons** instead of own photos — photos are heavy to store in a browser.
- **~40-product table** instead of a full nutrition database — enough to prove exact counting; own products cover the rest.

## Decisions and Open Issues
- Learner: exact counting, no AI; My Kitchen library in POC; 3D icons now, photos later; Flutter web.
- Implementation (agent, to confirm while viewing): Mifflin–St Jeor + 30 ml/kg water; glass = 250 ml; ready-made items counted per 100 g.
- Learner uncertainty: she wants to "see the whole task volumetrically" — the module map in this spec and the `app-map.html` at build end serve that.
- Open: final name of the "My Kitchen" button; ready-made by piece vs per 100 g.
