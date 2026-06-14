# Store Asset Inventory

This inventory records the current state of release-facing store assets.

The repository contains release notes, briefs, and a minimal launcher vector, but it does not yet contain the final exported Play Store asset set.

## Inventory

| Asset | Source file(s) | Final export status | Owner action required | Notes |
| --- | --- | --- | --- | --- |
| Launcher icon | `app/android/app/src/main/res/drawable/ic_launcher.xml` | `BLOCKED` | Export the final launcher icon set and replace the placeholder vector. | Current asset is a simple vector placeholder, not a final store-ready icon set. |
| Adaptive icon foreground/background | Not present | `BLOCKED` | Create the adaptive icon source artwork and export the Android icon set. | No dedicated adaptive icon source files were found in the repo. |
| Feature graphic | `docs/release/feature_graphic_brief.md`, `docs/release/google_play_submission_content_pack.md` | `NOT EXPORTED` | Export the final 1024 x 500 feature graphic. | Brief exists, but the final image file is not committed. |
| Phone screenshots EN | `docs/release/store_screenshot_plan.md`, `docs/release/google_play_submission_content_pack.md` | `NOT EXPORTED` | Capture the final English screenshot set from the app. | Screenshots should be real in-app captures only. |
| Phone screenshots PL | `docs/release/store_screenshot_plan.md`, `docs/release/google_play_submission_content_pack.md` | `NOT EXPORTED` | Capture the final Polish screenshot set from the app. | Keep the Polish overlays and app state aligned with the shipped build. |
| Optional tablet screenshots | Not planned | `DEFERRED` | Confirm whether tablet screenshots are required for the target release. | Optional unless owner policy or store guidance makes them necessary. |
| App listing text assets | `docs/release/store_listing.md`, `docs/release/store_listing_copy.md`, `docs/release/google_play_submission_content_pack.md` | `READY WITH OWNER ACTION` | Copy the final listing text into Play Console after owner confirmation. | Text is drafted but final publication values are owner-side. |

## Notes

- No misleading claims should be introduced into the final export set.
- No price promo text, awards, or ranking claims should appear in the assets.
- No ad overlays should appear in Journal, Settings, Privacy, or active audio screenshots.
- The final asset exports should be committed only if they are the intended release assets, not private Play Console exports.
