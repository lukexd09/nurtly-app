# Sounds MVP Behavior

For the current authoritative release status and blocker list, see [Final MVP release readiness](final_mvp_release_readiness.md) and [Final release blockers](final_release_blockers.md).

This document captures the current MVP Sounds behavior for release QA and store-readiness review.

It is not legal advice and does not describe future audio roadmap items beyond the current MVP.

## Current known behavior

- Sounds opens from the main shell as one of the primary tabs.
- The Sounds list loads bundled sound content from the app package.
- A sound card opens a sound detail/player screen.
- The player starts playback from the selected audio asset.
- The primary control toggles play and pause.
- The current detail screen does not expose a dedicated stop button.
- The selected sound remains the only active sound in the player UI flow.
- Timer presets are available: 15, 30, 60, and continuous play.
- When a timer is set, fade-out is applied near the end of the selected session.
- Continuous play keeps playback looping without a session timer.
- Loading and error states are shown in the Sounds list.
- A safety note is shown in the player to keep volume comfortable and the device away from the child.

## Release expectations

- The Sounds list must open without crashing.
- Sound loading must show a loading state and then rendered cards.
- Playback must start, pause, and resume predictably from the primary control.
- The user must be able to open a second sound after leaving the first sound detail view.
- Timer and fade-out behavior must not break playback or navigation.
- Loop behavior must stay stable for the current bundled audio assets.
- Error states must remain calm and readable.

## Known gaps

- There is no dedicated stop control in the current MVP player.
- Background audio is not implemented.
- Lock-screen controls are not implemented.
- There is no separate audio engine abstraction for this release slice.
- The player currently relies on the existing in-screen audio flow rather than a cross-app service.

## QA-relevant assumptions

- Only one sound is expected to be actively played from the current player screen at a time.
- If a second sound is chosen, the user flow is expected to navigate through the list and open the new sound detail screen.
- Timer and fade-out behavior are only expected inside the current detail screen.
- The current release assumes bundled audio assets are available locally in the app package.
- The current release assumes audio artwork is bundled alongside the sound metadata where present.

## Background audio status

- Status: post-MVP
- Reason: background playback is not implemented in the current MVP and would require separate product and technical scope before release.

## Audio license metadata expectations

- Each bundled sound should have clear source/license metadata in the content or release documentation before publication.
- If a sound asset source or license is unclear, mark it as `Needs owner confirmation`.
- The release path should not assume that bundled audio is free to use unless the asset provenance is documented.
- The current repo should keep release QA aligned with the documented asset provenance rather than inferred assumptions.

## Needs owner confirmation

- Final provenance and licensing details for bundled sound assets.
- Whether a dedicated stop control is needed before or after the MVP release.
- Whether background audio should be treated as a future spike, a later post-MVP item, or a separate product decision.
