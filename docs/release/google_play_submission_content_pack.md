# Google Play closed-testing submission content pack

This document collects the current closed-testing submission content for Issue #148.

It is a draft handoff pack for Google Play Console work only. No submission has been performed from this repository.

## Submission overview

- App: Nurtly
- Release path: Google Play closed testing
- Audience: parents and caregivers 18+
- Positioning: calm, parent-facing support app
- Product scope: play ideas, soothing sounds, local-only Journal, optional Premium
- Current MVP contract: free users may see passive banner ads in allowed browse areas, Premium removes ads

## Store listing copy

### English

#### App name

Nurtly

#### Short description

Calm sounds, play ideas, and a local care journal for parents.

#### Full description

Nurtly is a calm, parent-focused app for everyday routines.

Use it to explore soothing sounds, simple play and activity ideas, and a local daily care journal that helps you keep track of sleep, feeding, diaper changes, and notes in one place.

Nurtly is designed to feel practical, gentle, and privacy-conscious.

What you can do:

- play calming sounds for everyday routines,
- browse simple play and activity ideas,
- log sleep, feeding, diaper, and note entries in a local care journal,
- return to your day with a clear view of what happened and when.

Premium is optional.

- Free users may see ads.
- Premium users do not see ads.
- Premium also unlocks selected content where applicable.

Nurtly is not medical advice and does not provide diagnosis or sleep coaching.
Journal data stays on the device in the current implementation.

#### Release notes

This closed-testing build includes calming sounds, play ideas, and a local daily care journal.

Premium removes ads.
Free users may see passive banner ads in allowed browse areas only.

### Polish

#### Nazwa aplikacji

Nurtly

#### Krótki opis

Spokojne dźwięki, zabawy i lokalny dziennik opieki dla rodziców.

#### Pełny opis

Nurtly to spokojna, rodzicielska aplikacja na co dzień.

Pomaga odkrywać kojące dźwięki, proste pomysły na zabawy i aktywności oraz lokalny dziennik opieki, w którym możesz zapisywać sen, karmienie, pieluchę i notatki w jednym miejscu.

Nurtly ma być praktyczne, łagodne i przyjazne dla prywatności.

Co możesz zrobić:

- odtwarzać kojące dźwięki do codziennych rutyn,
- przeglądać proste pomysły na zabawy i aktywności,
- zapisywać sen, karmienie, pieluchę i notatki w lokalnym dzienniku opieki,
- wracać do dnia z czytelnym podsumowaniem tego, co się wydarzyło i kiedy.

Premium jest opcjonalne.

- Darmowa wersja może pokazywać reklamy.
- Premium usuwa reklamy.
- Premium odblokowuje też wybrane treści, jeśli dotyczy.

Nurtly nie udziela porad medycznych i nie służy do diagnozowania ani coachingu snu.
W obecnej implementacji dane dziennika pozostają na urządzeniu.

#### Informacje o wydaniu

Ta wersja zamkniętych testów zawiera kojące dźwięki, pomysły na zabawy oraz lokalny dziennik opieki.

Premium usuwa reklamy.
Darmowa wersja może pokazywać pasywne reklamy banerowe wyłącznie w dozwolonych obszarach przeglądania.

## Screenshot brief

Use the existing screenshot plan as the visual source of truth:

- Home / calm start
- Play ideas / activities
- Sounds player
- Journal dashboard
- Add Journal entry / custom picker
- Premium / privacy reassurance

Capture real in-app screens only.
Do not show ads in Journal, Settings, or active audio screenshots.
Do not use misleading claims, price promos, or child-facing language.

## Feature graphic brief

- Size: 1024 x 500 px
- Format: JPEG or 24-bit PNG, no alpha
- Tone: premium, calming, parent-facing
- Palette: muted sage green, warm off-white, soft grey-blue, beige
- Composition: centered visual, safe crop margins, no clutter
- Text: preferably none; if used, keep it short and localized
- Avoid: medical styling, child faces, promo claims, discounts, urgent language

## Data Safety draft

Draft the Play Console answers around the current MVP behavior:

- Journal data is local-only on the device.
- Journal content is not intended for cloud sync or backend upload in the MVP.
- No product analytics provider or SDK is planned for the MVP release.
- Billing is used for Premium subscriptions.
- Ads are allowed only as passive banner ads in browse areas under the current MVP contract.
- Advertising ID and ad personalization remain owner-confirmation items until the final ad setup is decided.

Likely review areas:

- app activity
- device or app info
- purchase history
- advertising ID
- diagnostics / crash logs
- user-provided content

Do not include Journal note content, child name, exact birthdate, health data, or child profiling in any analytics or data-safety narrative.

## Content rating / target audience notes

- Target audience: adults 18+, parents and caregivers
- Not directed to children
- Not medical
- Not a sleep coaching app
- Not a child optimization app
- Calm parenting support only

## Privacy policy handoff

Draft policies live here:

- [English privacy policy draft](../legal/privacy_policy_en.md)
- [Polish privacy policy draft](../legal/privacy_policy_pl.md)

The final policy URL and production wording must match the published app behavior and Play Console answers.

## Owner decisions needed

- See [Play Console owner decisions](play_console_owner_decisions.md) for the recommended defaults and remaining confirmations.

## Submission notes

- No app code was changed for this pack.
- No Google Play submission was performed from the repository.
- No private release configuration should be committed.
- Use this pack together with the checklist and store assets docs when preparing the Play Console submission.
