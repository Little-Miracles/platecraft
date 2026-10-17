# PlateCraft — Build Log

How the app changed while we built it, and why. Every change came from using
the app ourselves: cooking a real dish, logging a real coffee, and noticing
what felt wrong. The commit history has the matching code.

The rule that never changed: **AI helps name things, code does the math.**
Calories come from real ingredients and real formulas, never from a guess.

## 16 October — first screens

| What we changed | What we noticed | Why it matters |
|---|---|---|
| Ready-made food: "per 100 g" **or** "per serving" | A coffee typed as "250 kcal" became 625 kcal (read as 250 kcal per 100 g × 250 g) | Labels give per-100 g, cafés give per cup — both must be exact |
| Drinks in **ml**, teaspoon / tablespoon helpers | Nobody weighs sugar for coffee; everyone knows "2 teaspoons" | Real kitchens measure in spoons and cups |
| Five kinds of coffee listed first | People look for *their* name ("instant", "Turkish") and worry if it's missing, even when calories are the same | Trust comes from recognising your own food |
| Ingredients sorted by section (baked, drinks, soups, mains) | Potatoes and cabbage were offered for a croissant | Less scrolling, fewer mistakes |
| A week strip instead of "Today" | One day of numbers says little | Habits show up over a week |
| Home shows only results; meals moved to their own page | Home became a "vinaigrette" of banner, week, tiles and meals | One screen, one job |
| An intro with a golden calculator before the first visit | New users didn't know where to start | The daily goal comes first, everything else builds on it |
| Gold of the logo, Marcellus lettering, emerald "pearl" panels | Several gold shades and fonts on one screen looked messy | One visual language |

## 17 October — two flows, no scales needed

| What we changed | What we noticed | Why it matters |
|---|---|---|
| The intro line types **once** and stays, then the calculator appears | Typing the same line three times looked like a glitch | Calm, not repetitive |
| **Two flows.** A meal is where dishes are made (Homemade / Ready-made right there). **Saved dishes** only holds what you made — add it to any meal, edit, delete | The "Recipes" book repeated the meals: the whole app *is* your recipes | Make once in the moment, reuse forever |
| Saving a dish does two things: its portion goes into the meal, its recipe into Saved dishes — with a message saying so | You must know where your dish went | No lost dishes |
| **The finished weight is estimated** from the raw weight and the cooking method (soup −10% water, stew −15%, frying −25%, oven −15%). Weighed it? Your number replaces ours | One person weighs the pot, another never will | Exact for those who weigh, close for those who don't |
| Portions start at a usual size: cup 250 ml, bowl of soup 300 g, plate 250 g, slice 100 g; a homemade cup is the cup you made | Asking "how many grams?" every time is tiring | One tap to log |
| **Protein, fat, carbs** for all 102 products (net carbs, like EU labels), carried through dishes and meals to the home banner | Calories alone don't show what you ate | The standard three numbers, computed — not typed |
| Food pictures on black tiles, like the logo | The 3D pictures were drawn on black; on green they looked flat | Depth, and one look with the logo |
| **Bug fix:** the week strip and water drops on home update at once | The banner said 60 kcal eaten, the week said "No meals logged this week yet" | Every number on home must agree |
| Week columns taller, in the plate's gold, with the day's kcal above | Columns were 3 px high and easy to miss | You see your week at a glance |

## The formulas

- **Daily calories:** Mifflin–St Jeor basal rate × activity factor (1.2 – 1.9).
- **Water:** 30 ml per kg of body weight.
- **Finished weight:** sum of raw ingredients × cooking yield
  (no cooking 1.0 · boiled/soup 0.9 · stewed 0.85 · fried 0.75 · baked 0.85),
  unless you enter your own weight.
- **Per 100 g:** everything that went into the pot ÷ finished weight × 100 —
  for kcal, protein, fat and carbs alike. Drinks per 100 ml (1 ml ≈ 1 g).
- **A portion:** per-100 value × portion ÷ 100.

## Checked by tests

`test/flow_test.dart` cooks a borscht in code (estimated weight, per 100 g,
usual portion, day totals), checks that old saved data still loads and that
home updates the moment a meal or water is added.
`test/layout_smoke_test.dart` lays out every main screen on two phone sizes.
