# Google Play reviewer access

Use this text in Google Play Console when submitting a build that contains restricted or Premium areas.

## Play Console instructions

1. Open the app and go to `Settings`.
2. In the `About` section, open `Reviewer access`.
3. Enter the reviewer code: `NURTLY-REVIEWER-162`.
4. Tap `Activate reviewer access`.
5. Confirm that the dialog shows the active reviewer-access message.
6. After activation, all restricted Premium areas are available without purchase.
7. Reviewer access stays on this installation after the app is restarted.

If you need to test the flow again on the same installation, open the same `Reviewer access` dialog and tap `Reset reviewer access`.

## QA notes

- Activation should work offline.
- An invalid code must not enable reviewer access.
- After activation, Premium content and restricted areas should be reachable without purchase.
- Reviewer access must remain active after a full app restart.
- Reset must disable only reviewer access and must not affect local journal data, language preferences, Google Play purchases, or UMP state.
- True Google Play Premium must continue to work independently of reviewer access.
- Reviewer access must suppress ads the same way Premium does.
- QA should verify restricted activities and sounds as well as the rest of the Premium-gated surfaces.
