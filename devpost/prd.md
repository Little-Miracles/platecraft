---
doc: prd
status: final
---

# PlateCraft — Product Requirements

A web app for people who watch calories and cook for themselves: build each dish once from real ingredients, then always know its exact calories.
Source: `scope.md > The Unique Kernel`, `scope.md > Who It's For`.

## The Core Journey
1. The user opens PlateCraft and sees the start screen with the logo; taps **Start**.
2. Home screen: a banner at the top (daily target, eaten today, water) and two big buttons — **Calculator** and the food builder (working name **My Kitchen**).
3. First visit: the banner invites the user to open the Calculator. They enter sex, age, height, weight and activity, pick an avatar icon, and save. The banner now shows their daily calories and water.
4. They tap the food builder → choose a meal: breakfast, lunch, dinner, snack, or water.
5. Inside a meal they choose a category: drinks, baked goods, soups, main dishes.
6. In a category they either:
   - pick a dish already saved in **My Kitchen** and enter how many grams they ate, or
   - add a **ready-made** item: name, kcal per 100 g (from the package), grams eaten, or
   - build a **homemade** dish: add ingredients with grams (from the built-in product table or their own product), enter the weight of the finished dish → see kcal per 100 g → name it, pick a 3D icon, save it to My Kitchen → enter the portion eaten.
7. Save → back on the home screen, "eaten today" grows; the meal shows what was eaten.
8. Next day: the borscht is already in My Kitchen — weigh the plate, enter grams, done.

Success: steps 4–7 work for a homemade soup end to end (`scope.md > What "Working" Looks Like`).

## Screens and Layout
- **Start** — logo, name, Start button.
- **Home** — banner (target / eaten / remaining, water progress), Calculator button, My Kitchen button, today's meals summary.
- **Calculator** — form + avatar picker + result card.
- **Meals** — five meal tiles (breakfast, lunch, dinner, snack, water).
- **Meal** — four category tiles + list of what is already eaten in this meal.
- **Category** — saved dishes of this category from My Kitchen (with 3D icons) + buttons "Ready-made" and "Homemade".
- **Dish builder** (homemade) — ingredient list with grams, product search, "add my own product", finished weight, live kcal per 100 g, name + icon, save.
- **Ready-made form** — name, kcal per 100 g, grams eaten, icon.
- **Portion sheet** — grams eaten → kcal for this portion → Add.
- **Water** — "+ glass" (250 ml) and progress toward the daily water target.

## Look and Feel
From `scope.md > Inspiration & Identity`: emerald background, gold accents, purple highlights; elegant serif headings echoing the logo, clean sans body. Premium, calm, precise. Volumetric 3D icons (not flat) for food and avatars — e.g. a reddish one for borscht, a light one for broth.

## Features and Behavior

### Daily calculator
- Calories: Mifflin–St Jeor BMR × activity factor. Water: 30 ml per kg of body weight.
- Result shows in the home banner immediately and survives a page reload.

### My Kitchen (dish builder + library)
- kcal per 100 g of a homemade dish = sum of (ingredient grams × ingredient kcal/100 g) ÷ finished weight × 100.
- The finished weight is entered by the user (water boils off, food absorbs water) — this is what makes it exact.
- A saved dish keeps its ingredients, finished weight, kcal/100 g, category and icon.
- As someone who cooks a pot of borscht for three days, I want to save it once so that next time I only weigh my plate.
  - [ ] A saved dish appears in its category with its icon.
  - [ ] Choosing it and entering 300 g shows the exact portion kcal and adds it to today.

### Ready-made food
- Name + kcal per 100 g + grams eaten → portion kcal. Optional save to My Kitchen for reuse.

### Product table
- ~40 common products with kcal per 100 g, searchable by name. The user can add their own product (name + kcal per 100 g from the package); it is remembered.

### Water
- "+ glass" adds 250 ml; banner shows ml drunk vs target.

## States and Boundaries
- **First use** — no profile: banner says "Set your daily target" and points to Calculator; meals still work.
- **Empty category** — no saved dishes yet: friendly hint to build the first one.
- **Invalid input** — finished weight 0 or empty, or no ingredients: Save disabled, kcal shows "—".
- **Persistence** — profile, My Kitchen, own products and today's entries are stored in the browser and survive reload. A new calendar day starts with an empty "eaten today".

## Product Decisions
- Exact over approximate: no AI estimates — learner's core reason for the app.
- My Kitchen library is in the POC — "this is the most important": cook once, reuse.
- Built-in 3D icons now, own photos later — photos are heavy in a browser prototype.
- One builder for every category — the mechanism is the same for soup, cupcake or cocktail.

## What We're Building
Everything in `scope.md > The POC Boundary`: start, home with banner, calculator with avatar, meals → categories, ready-made and homemade paths, My Kitchen library with 3D icons, product table + own products, water.

## Deferred From the POC
- Own photos for dishes/avatar — storage in browser is heavy.
- History by day and charts — "today" is enough to prove the kernel.
- Macros (protein/fat/carbs) — calories first.
- Moving into Smart Body Life — after the hackathon.

## Possible Later Enhancements
- Scale a saved recipe ("I made a double pot").
- Share a dish card.

## Non-Goals
- AI, photo or voice recognition — contradicts the kernel.
- Accounts, login, cloud sync — not needed for one person's prototype.
- Built-in text in other languages — the app is English; the globe translates on the fly.

## Open Questions
- Final name for the food-builder button (working name "My Kitchen") — can wait, learner decides while viewing.
- Ready-made items by piece ("1 cupcake = 250 kcal") instead of per 100 g — can wait, decide while viewing.
