# Nurtly UI Design Direction A — Flutter Implementation Spec

## 1. Purpose

This document translates the accepted Stitch visual direction into an implementation-ready UI specification for Flutter/Codex.

The Stitch export is a visual reference, not a pixel-perfect source of truth.

Codex should implement the visual language, component mood, spacing, hierarchy and UX principles described here, while following the Nurtly SSOT, AGENTS.md and MVP scope.

## 2. Accepted design direction

Name:

**Design Direction A — Calm Premium Parenting**

Status:

**Accepted for implementation reference**

Visual keywords:

- calm,
- warm,
- premium,
- parent-focused,
- trustworthy,
- soft,
- practical,
- minimal,
- not childish,
- not medical,
- not gamified.

Design system mood:

**Modern Minimalist with Tactile Warmth**

## 3. Product framing for UI

Nurtly is an app for parents/caregivers 18+, not for children.

The UI must feel like a calm daily companion for a parent who may be tired, distracted, holding a child, or using the app at night.

The product supports:

1. screen-free play ideas,
2. a local child journal,
3. calming sounds.

The UI should not feel like:

- a children’s game,
- a medical app,
- a developmental assessment tool,
- a gamified productivity app,
- a social/memory-sharing app.

## 4. Implementation rule: Stitch is reference, not requirement

Implement:

- calm color palette,
- soft rounded cards,
- generous spacing,
- bottom navigation,
- parent-focused dashboard,
- practical activity cards,
- journal timeline,
- simple add-entry flow,
- calming sound player,
- clear Privacy & Data screen.

Do not blindly copy:

- stock/AI images,
- child face imagery,
- exact copy from Stitch,
- gamification elements,
- overly developmental claims,
- unsupported future features,
- anything outside MVP.

## 5. Core visual principles

### 5.1. Calm first

The UI should reduce cognitive load.

Use:

- muted colors,
- warm backgrounds,
- clear card separation,
- simple labels,
- minimal decorative elements,
- calm empty states.

Avoid:

- strong contrast unless needed for accessibility,
- neon colors,
- visual clutter,
- multiple competing CTAs,
- animated/childlike visuals,
- aggressive gamification.

### 5.2. Parent utility over decoration

The UI should help a parent quickly decide what to do.

Every screen should answer:

- What can I do here?
- What is the fastest next action?
- What information matters right now?

### 5.3. One-hand friendly

Controls should be thumb-friendly.

Use:

- large tap targets,
- bottom navigation,
- clear primary actions,
- forms with minimal friction,
- visible save/add actions.

### 5.4. Accessible by default

Implementation should consider:

- readable type sizes,
- sufficient contrast,
- non-color-only meaning,
- clear labels,
- scalable text where possible,
- safe spacing between tappable elements.

## 6. Design tokens

Exact values may be adjusted during Flutter implementation, but the following direction should be preserved.

### 6.1. Color palette

Recommended color roles:

```text
Background / Cream: #FBF9F5
Surface / Card: #FFFFFF or #FFFDF8
Primary / Sage: #4A654F
Primary Soft: #DDE8DD
Secondary / Sand: #E8DCC8
Accent Warm: #C99A6B
Text Primary: #243028
Text Secondary: #68746B
Text Muted: #9BA49C
Border Soft: #E8E3DA
Success Soft: #DDE8DD
Warning Soft: #F4E6C8
Error Soft: #F3D6D0
```

Guidelines:

- Use cream/off-white as the main background.
- Use sage green as the primary action/accent.
- Use sand/beige as supportive warmth.
- Avoid bright baby pink/blue as primary brand colors.
- Keep the palette gender-neutral and parent-oriented.

### 6.2. Typography

Preferred direction:

- modern,
- rounded,
- highly readable,
- friendly but not childish.

Suggested font families from Stitch direction:

- Plus Jakarta Sans for main UI,
- Quicksand may be used cautiously for softer headings if readability remains strong.

Flutter fallback:

Use a consistent Google Font if available and acceptable for the project setup. Otherwise use system fonts initially and keep typography tokens ready for later refinement.

Recommended type scale:

```text
Display / Hero: 28–32sp, semibold/bold
Screen title: 24–28sp, semibold
Section title: 18–20sp, semibold
Card title: 16–18sp, semibold
Body: 14–16sp, regular
Caption / metadata: 12–13sp, medium/regular
Button: 15–16sp, semibold
```

### 6.3. Radius

Use soft, modern radii:

```text
Small controls: 10–12px
Chips: 999px / pill
Cards: 20–24px
Large panels: 24–28px
Bottom sheets: 28px top radius
```

### 6.4. Spacing

Use an 8px spacing system:

```text
4px micro
8px small
12px small-medium
16px default
24px section
32px large
```

Guidelines:

- Prefer generous vertical rhythm.
- Keep list cards scannable.
- Avoid dense enterprise-style layouts.

### 6.5. Shadows and borders

Use subtle shadows only.

Cards may use:

- soft border,
- very light shadow,
- or elevation-like surface separation.

Avoid heavy Material-style shadows.

## 7. Core components

### 7.1. App shell

MVP navigation:

Bottom tabs:

1. Play
2. Journal
3. Sounds

Settings / Privacy access:

- top-right icon on Home, or
- accessible from a simple settings/profile icon.

Do not add more primary navigation tabs in MVP.

### 7.2. Bottom navigation

Requirements:

- clearly visible active tab,
- large enough tap targets,
- labels visible,
- calm icon style,
- no childlike icons.

Tabs:

```text
Play
Journal
Sounds
```

### 7.3. Cards

Cards are the main surface pattern.

Use for:

- quick actions,
- activity cards,
- journal entries,
- sound cards,
- privacy/data info blocks,
- summary panels.

Card style:

- soft radius,
- warm white surface,
- subtle border or shadow,
- clear title,
- short supportive copy,
- metadata chips where useful.

### 7.4. Chips

Use chips for:

- filters,
- activity metadata,
- journal entry types,
- sound categories.

Chips should be readable and not too small.

### 7.5. Primary button

Style:

- sage green background,
- light text,
- rounded pill or rounded rectangle,
- strong but not aggressive.

Use one primary CTA per screen where possible.

### 7.6. Secondary button

Style:

- cream/white background,
- sage/dark text,
- soft border.

Use for non-primary actions.

### 7.7. Forms

Forms should be fast and simple.

Guidelines:

- large fields,
- clear labels,
- minimal required input,
- good default values,
- thumb-friendly controls,
- no unnecessary decorative imagery in functional form space.

### 7.8. Timeline

The journal timeline is a core component.

Style:

- date header,
- vertical timeline line or grouped list,
- cards for each entry,
- entry type icon,
- time clearly visible,
- short content summary.

## 8. Screen specifications

## 8.1. Home / Today dashboard

### Purpose

Give the parent fast access to the three core areas and a calm overview of today.

### Required elements

- Header with greeting or Today title.
- Settings/privacy access icon.
- Quick action cards:
  - Find a play idea,
  - Add journal entry,
  - Start calming sound.
- Today / recent summary area.
- Optional gentle prompt for today’s play idea.
- Optional latest journal entries preview.

### Recommended sections

```text
Header
Quick Actions
Today’s play idea
Recent journal moments
Calming sounds shortcut
```

### Avoid

- gamified weekly goals,
- streaks,
- productivity pressure,
- “complete X activities” messaging.

### Copy direction

Good examples:

```text
Simple ideas for calm, connected moments.
Track the small things that matter today.
Choose a sound for a quiet moment.
```

Avoid:

```text
Support infant development
Complete your weekly goal
Boost your child’s intelligence
```

## 8.2. Play Ideas list

### Purpose

Help a parent quickly choose a screen-free activity that fits the current situation.

### Required elements

- Screen title.
- Filter access.
- Activity cards.
- Metadata chips.
- Clear card CTA / tap interaction.

### Required filters

The UI architecture must support:

- age group,
- place,
- situation,
- child engagement,
- parent involvement,
- mess level,
- activity type.

Not all filters need to be expanded at once. A filter sheet/dialog is acceptable.

### Activity card content

Each card should show:

- title,
- short description,
- age group,
- practical tags,
- optional image/illustration/icon,
- clear affordance to open details.

Preferred tags:

```text
Home
Low mess
Child: Medium
Parent: Low
Sensory
Calm
Movement
Creative
```

### Duration rule

Duration must not be the main activity attribute.

If shown, duration should be secondary and soft:

```text
Short activity
Flexible length
```

Avoid prominent exact duration badges such as:

```text
5 min
10 min
15 min
```

### Visual asset rule

Prefer:

- neutral illustrations,
- object-focused images,
- soft abstract visuals,
- no child faces.

Avoid:

- AI baby portraits,
- mixed visual styles,
- fantasy landscape images,
- stocky family photos with faces.

## 8.3. Activity Detail

### Purpose

Show one activity clearly so the parent can try it without confusion.

### Required elements

- Activity title.
- Age group.
- Place/situation.
- Needed items.
- Mess level.
- Child engagement.
- Parent involvement.
- Step-by-step instructions.
- Parent note.
- Light safety note where relevant.

### CTA

Use soft CTA language:

```text
Save idea
Try this idea
Back to ideas
```

Avoid:

```text
Complete Activity
Finish challenge
Mark as completed
```

No gamification in MVP.

### Development claims rule

Do not make strong claims.

Use:

```text
may support
encourages
helps practice
invites your child to explore
```

Avoid:

```text
develops intelligence
guarantees better focus
improves speech development
```

## 8.4. Journal Timeline

### Purpose

Show today’s child journal entries in a fast, clear, timeline-like view.

### Required elements

- Date header.
- Date navigation.
- Filter chips:
  - All,
  - Sleep,
  - Feeding,
  - Diaper,
  - Note.
- Vertical timeline or grouped list.
- Entry cards.
- Add entry button.
- Empty state.

### Entry card content

Each entry card should show:

- entry type,
- time or time range,
- short summary,
- optional note preview,
- edit affordance if implemented.

Entry types:

```text
Sleep
Feeding
Diaper
Note
```

### UX requirements

- one-hand friendly,
- quick scanning,
- no clutter,
- no social/memory-sharing feeling,
- local-only data expectation.

### Empty state example

```text
No entries yet today.
Add the first moment when you’re ready.
```

## 8.5. Add Journal Entry

### Purpose

Allow tired/busy parents to add an entry quickly.

### Required elements

- Entry type selector:
  - Sleep,
  - Feeding,
  - Diaper,
  - Note.
- Date/time fields.
- Type-specific fields.
- Optional note.
- Save button.

### Type-specific fields

Sleep:

- start time,
- end time.

Feeding:

- time,
- feeding type/source,
- optional amount,
- optional note.

Diaper:

- time,
- type:
  - pee,
  - poop,
  - both,
  - dry.

Note:

- time,
- note text,
- optional simple tag.

### Visual rule

Reduce decorative imagery in forms.

Function and speed are more important than decoration.

## 8.6. Sounds Library

### Purpose

Let the parent choose a calming sound.

### Required categories

```text
Noise
Nature
Home
Travel
Classical / Calm
```

### Sound card content

Each card should show:

- sound title,
- category,
- short description or metadata,
- play/open affordance,
- access state if needed later.

### MVP rules

- one sound at a time,
- no playlists,
- no mixes,
- no share feature,
- no save-to-library feature unless explicitly added later.

## 8.7. Sound Player

### Purpose

Play one calming sound in a calm, low-friction interface.

### Required elements

- sound title,
- category or short description,
- large play/pause control,
- timer options:
  - 15 min,
  - 30 min,
  - 60 min,
- fade out indicator/toggle,
- volume/safety note,
- calm visual treatment.

### Safety note copy direction

Example:

```text
Keep the volume comfortable and place the device away from your child.
```

### Avoid

- share sound,
- save to library,
- social features,
- loud promotional prompts,
- ads during playback.

## 8.8. Privacy & Data

### Purpose

Explain privacy clearly and calmly.

### Required elements

- Heading: Privacy & Data.
- Simple explanatory cards.
- Link/button to Privacy Policy.
- Contact us option.

### Required cards / topics

```text
Nurtly is for parents/caregivers.
Journal data stays on this device in MVP.
We do not collect journal notes.
Analytics are minimal.
Ads help keep Nurtly free.
```

### Tone

Practical and transparent.

Avoid overly dramatic wording such as:

```text
Your Privacy is Sacred
```

Prefer:

```text
Your data, simply explained.
```

or:

```text
How Nurtly handles your data.
```

## 9. Asset guidelines

### 9.1. Preferred asset style

Use one consistent style.

Preferred:

- soft abstract shapes,
- simple object illustrations,
- neutral lifestyle fragments without faces,
- icons,
- soft gradients/patterns.

### 9.2. Avoid

Avoid:

- AI-generated baby faces,
- child portraits,
- mixed stock photo styles,
- fantasy landscapes,
- overly cute cartoon characters,
- medical imagery,
- diagnostic/clinical visuals.

### 9.3. MVP asset strategy

For MVP implementation, it is acceptable to use:

- icons,
- gradients,
- abstract cards,
- simple placeholder visuals,
- no large photo library.

This reduces licensing, privacy and visual consistency risk.

## 10. Copywriting rules for UI

### 10.1. Tone

Use tone that is:

- calm,
- supportive,
- practical,
- direct,
- non-judgmental,
- parent-focused.

### 10.2. Avoid pressure

Avoid language that makes parents feel judged or behind.

Avoid:

```text
You haven’t completed today’s activities.
You missed your goal.
Your child should...
```

Prefer:

```text
Choose what fits your day.
Add a note when you’re ready.
Here are a few simple ideas.
```

### 10.3. Avoid unsupported claims

Avoid:

- medical claims,
- guaranteed sleep claims,
- strong developmental claims,
- diagnostic language.

Prefer:

- may help,
- can support,
- encourages,
- helps create a calm routine.

## 11. What to exclude from MVP UI

Do not implement unless explicitly scoped later:

- onboarding-heavy flow,
- account creation,
- multiple child management UI,
- parent sync,
- export PDF/CSV,
- remove ads purchase flow,
- streaks,
- weekly activity goals,
- social sharing,
- sound sharing,
- custom playlists,
- activity completion tracking,
- advanced charts,
- medical/allergy workflows.

## 12. Flutter implementation notes

### 12.1. Suggested structure later

When UI implementation begins, consider organizing Flutter code by feature:

```text
app/lib/
  core/
    theme/
    localization/
    widgets/
  features/
    home/
    activities/
    journal/
    sounds/
    privacy/
```

Do not create this structure unless the relevant task explicitly asks for Flutter skeleton or UI implementation.

### 12.2. Theme

Create a central theme when implementation starts.

Theme should include:

- color tokens,
- typography tokens,
- radius constants,
- spacing constants,
- shared card/button styles.

### 12.3. Reusable widgets

Likely reusable widgets:

- NurtlyCard,
- NurtlyChip,
- PrimaryButton,
- SecondaryButton,
- BottomNavScaffold,
- SectionHeader,
- EmptyState,
- JournalTimelineItem,
- ActivityCard,
- SoundCard.

### 12.4. Product name

Do not hardcode `Nurtly` everywhere.

Use central app configuration/localization where possible.

## 13. UI QA checklist

Before accepting UI implementation, verify:

- UI follows Calm Premium Parenting direction.
- No child-targeted visuals.
- No medical/diagnostic tone.
- No unsupported developmental claims.
- Bottom navigation has Play / Journal / Sounds.
- Activity duration is not dominant.
- Activity filters support age/place/engagement/mess/type.
- Journal timeline is fast and readable.
- Add entry flow is simple and one-hand friendly.
- Sound player has timer and fade-out.
- Ads do not appear in prohibited moments.
- Privacy & Data screen is clear and simple.
- EN/PL localization is considered.
- Touch targets are large enough.
- Text contrast is acceptable.
- Layout works on common mobile widths.
- No secrets, external SDKs or non-MVP features added by accident.

## 14. Implementation status

Design exploration status:

**Closed.**

Accepted reference:

**Final Stitch export — Design Direction A / Calm Premium Parenting.**

Next recommended work:

1. Add this design spec to repo documentation.
2. Create UI/design implementation epic later.
3. Use this spec as reference when creating Flutter UI tasks.
4. Keep product decisions governed by SSOT and AGENTS.md.

