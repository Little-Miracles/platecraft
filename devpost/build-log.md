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
| **A language globe**: English, Ukrainian, German, French. One choice changes every screen and is remembered | We were holding a phone with Google Translate over the screen to read our own app | People cook in their own language |
| Translation **on the fly**: each phrase goes to a translator and comes back; kept only in memory. No translation files inside | Shipping word lists for every language makes the app heavy with text most people never see | Light app; without internet it simply stays in English |
| Product search in your language ("буряк" finds Beetroot) | The product table is in English | Nobody has to know the English word for their vegetable |
| **Pick by size**: +1 small / medium / large egg, an apple with its size in cm, a clove, a slice | Nobody weighs an egg; people choose a size by eye | Logging stays quick, grams stay possible |
| Five fruits added, and quail egg for broth | A morning fresh juice needed oranges; broth often gets quail eggs | The table follows real cooking |
| **Product** — a third way into a meal for food eaten as it is | Sour cream for the borscht, butter, an apple are neither cooked nor a labelled ready-made dish | Borscht from Saved dishes + 2 tablespoons of sour cream, in two taps |
| Fruit gets the apple picture; the icon choice in Ready-made moved up | A snack apple showed a cupcake, and the icon choice was hidden at the bottom | The picture matches the food |
| **Three goals** in the calculator: health, lose weight, gain weight (target ×1.0 / −15% / +10%) | The same 1,500 kcal is a success for one person and too little for another | Every number is read against *your* goal |
| **A caring evening card** from 20:30: eaten of target, read by the goal; water with "check with your dietitian". Away for a few days? It talks about the last day you logged, with its date | A tracker that only collects numbers feels cold | Soft words, no fireworks, never blame |
| Every product has its own picture (31 more from the same Fluent set; a beetroot drawn for the app in the same style) | A strawberry showed as an apple — in a demo that reads as a mistake | Details that match build trust |
| Translation fixes: the whole week as one phrase, full shelf names, "My saved dishes" | Short words alone came back wrong ("Fr" → "О", "Main" → "Головна") | The translator needs context, like a person |
| **Backup: save all data to a file, restore it on a new phone** | Without a server, a new phone would start empty | Your kitchen and your history move with you |

## 18 October — the demo video

No code today: a full check (`flutter analyze` clean, all tests pass), then the
video. Nataliia recorded the real app, used with her real data; AI cut the
recordings with ffmpeg; she put it together in Canva with her own music.

| What we did | What we noticed | Why it matters |
|---|---|---|
| Recorded the real path in pieces: morning card → coffee → water → calculator → homemade borscht → portion → library → globe | The first single take ran over 2 minutes and was still at the start | Short pieces: a mistake costs one piece, not the whole take |
| AI looked at every recording frame by frame and cut it: slow typing ×4, ingredient picking ×3.4, the result screens at normal speed | A judge needs time to read the numbers, not to watch typing | The kernel (ingredients → kcal per 100 g → portion) stays readable |
| Cut out a search that found nothing ("pom…" — Polish for orange) | The app translates English, Ukrainian, German, French — not Polish yet | Honest demo: we show what works today |
| Reordered the pieces so the numbers only go up: 10 → 259 → 296 kcal | Recorded out of order, the home banner jumped back | Every number on screen must agree |
| Library recorded separately | The first recordings never opened Saved dishes — the heart of "make once, reuse forever" | Show the core, not only the setup |
| Dishes named in Ukrainian (борщ, кава, сирник) kept on screen | First seen as a slip in an English video | It shows the point: you name your food in your own language |
| Vertical phone recording placed on a 16:9 emerald background | Devpost and YouTube players are wide; a narrow strip looks lost | Captions sit beside the phone and never cover the app |
| Captions: Nataliia says it in her own language, AI translates close to her words | She doesn't speak English on camera | Her words, not a marketing script |
| **Background music composed by AI in code** (`tool/compose_music.py`): soft pad, piano arpeggio, bass, a slow melody in C major, 72 BPM, 3 min, fades to silence | Nataliia: "let it be one more thing we made together" — no stock tracks | Every sound in the video is ours, made the same way as the app |

## What comes next (not in this prototype)

- **AI that fills in products from a global food library.** Type "Golden
  Delicious apple" or the name on a cupcake label, and AI finds the product
  with its calories, protein, fat and carbs, ready to add. This needs an AI
  key, and the key must live on our own server (a proxy), never inside the
  app. This hackathon's task doesn't use keyed AI, so the prototype keeps a
  built-in table and lets you add your own products by hand.
- The same server would carry the translations, instead of the free public
  translator the prototype uses.
- Your own photo of a dish instead of an icon.
- The backup file goes to the cloud by itself and comes back on a new phone.
- A real push message at 20:30 in the phone app (as in our Smart Body Life);
  in the browser the evening card waits on the home screen instead.

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
