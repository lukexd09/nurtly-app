# Store Screenshot Plan

This is the authoritative screenshot plan for the Play Store release pack.

Use actual in-app captures only. Do not fabricate completed screenshots.

## Capture matrix

| Screen | App state | Language | Setup required | Expected caption / message | Privacy-safe sample data | Ads / Premium state visible | Capture status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Home | Cold app start on the main shell | EN | Fresh launch with stable tab bar visible | Calm start / parent-first home | No sensitive data required | If visible, only passive browse-area banner in the free state | Not captured |
| Home | Cold app start on the main shell | PL | Fresh launch with stable tab bar visible | Spokojny start dnia | No sensitive data required | If visible, only passive browse-area banner in the free state | Not captured |
| Play | Activity list | EN | Open Play from the shell | Play ideas / practical activity cards | Use neutral sample play ideas from bundled content | Free state can show a passive banner only in the allowed browse area | Not captured |
| Play | Activity list | PL | Open Play from the shell | Pomysły na zabawy / kartki aktywności | Use neutral sample play ideas from bundled content | Free state can show a passive banner only in the allowed browse area | Not captured |
| Sounds | Sounds list or player detail | EN | Open Sounds from the shell; show either list or player depending on the cleanest crop | Soothing sounds / calm playback | Use bundled sound titles only | Prefer a free state if the banner slot is visible in the list; never show ads in active playback | Not captured |
| Sounds | Sounds list or player detail | PL | Open Sounds from the shell; show either list or player depending on the cleanest crop | Kojące dźwięki | Use bundled sound titles only | Prefer a free state if the banner slot is visible in the list; never show ads in active playback | Not captured |
| Journal | Journal dashboard | EN | Open Journal with a clean day view | Local care journal | Use neutral sample entries only if needed | No ads visible | Not captured |
| Journal | Journal dashboard | PL | Open Journal with a clean day view | Lokalny dziennik opieki | Use neutral sample entries only if needed | No ads visible | Not captured |
| Journal add flow | Add entry / picker | EN | Open a create/edit flow | Quick care logging | Use privacy-safe sample data only | No ads visible | Not captured |
| Journal add flow | Add entry / picker | PL | Open a create/edit flow | Szybki zapis dnia | Use privacy-safe sample data only | No ads visible | Not captured |
| Premium / privacy reassurance | Paywall or settings reassurance | EN | Open Premium or Privacy & Data, whichever best reflects the release story | Premium is optional / privacy reassurance | No personal or sensitive data | Show Premium state, not ads in sensitive flows | Not captured |
| Premium / privacy reassurance | Paywall or settings reassurance | PL | Open Premium or Privacy & Data, whichever best reflects the release story | Premium jest opcjonalne / prywatność | No personal or sensitive data | Show Premium state, not ads in sensitive flows | Not captured |

## Capture rules

- Do not show ads in Journal, Settings, Privacy, legal, paywall, or active audio screenshots.
- Do not show debug labels, test IDs, or internal release notes.
- Keep the first screenshot in each language calm and uncluttered.
- Use the same bundled content across captures so the store assets remain consistent.
- If a screen cannot be captured cleanly, mark it as blocked instead of forcing a bad export.

## Notes

- Use this plan together with `docs/release/store_asset_inventory.md`.
- The screenshot plan is not proof that the assets are complete.
- Real-device captures are still required before Play Console upload.
