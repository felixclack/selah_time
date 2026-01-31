# Selah

Selah is an iOS 17+ SwiftUI app that pauses selected apps using Screen Time and asks for a short prayer before each unlock.

## Requirements
- Xcode 15+
- iOS 17+ device (Screen Time APIs require a physical device)
- Approved entitlement: `com.apple.developer.family-controls`

## Project setup
1. Generate the Xcode project:
   ```sh
   xcodegen generate
   ```
2. Open `Selah.xcodeproj` in Xcode.
3. Set your `DEVELOPMENT_TEAM` and update bundle identifiers if needed.
4. Ensure the App Group (`group.com.goodstack.selah`) exists in your Apple Developer account.

## Targets
- `Selah` (main app)
- `SelahShieldExtension` (`ShieldConfigurationExtension`)
- `SelahDeviceActivityExtension` (`DeviceActivityMonitor`)

## Notes
- No network calls in the MVP.
- Prayer templates live in `Sources/Selah/Resources/PrayerTemplates.json`.
- Screen Time shielding is applied using `FamilyControls`, `ManagedSettings`, and `DeviceActivity`.

## Acceptance checklist
See `Documentation/ManualTestChecklist.md`.

## fastlane
See `fastlane/README.md` for App Store automation, signing, and TestFlight lanes.
