# Google Play reviewer access

Use this text in Google Play Console when submitting a build that contains restricted or Premium areas.

## Play Console instructions

1. Open the app and go to `Settings`.
2. In `About`, tap the section title five times to open the hidden `Reviewer access` dialog.
3. Enter the reviewer code: `NURTLY-REVIEWER-162`.
4. Tap `Activate reviewer access`.
5. If the code is valid, the dialog closes and a confirmation SnackBar appears.
6. After activation, all restricted Premium areas are available without purchase on that installation.
7. Reviewer access stays on this installation after the app is restarted.

To test the flow again on the same installation, open `Settings`, tap `About` five times again, then use `Reset reviewer access`.

## QA notes

- Activation should work offline.
- An invalid code must keep the dialog open and must not enable reviewer access.
- After activation, Premium content and restricted areas should be reachable without purchase.
- Reviewer access must remain active after a full app restart.
- Reset must disable only reviewer access and must not affect local journal data, language preferences, Google Play purchases, or UMP state.
- True Google Play Premium must continue to work independently of reviewer access.
- Reviewer access must suppress ads the same way Premium does.
- QA should verify restricted activities and sounds as well as the rest of the Premium-gated surfaces.
