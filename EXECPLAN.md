# ExecPlan: Selah MVP Build

## Goal
Deliver an iOS 17+ SwiftUI app called "Selah" that blocks selected apps via Screen Time and requires a prayer flow on every unlock. The build includes the main app plus a `ShieldConfigurationExtension` and a `DeviceActivityMonitor` extension, offline-only data, and bundled prayer templates.

## Scope
- SwiftUI iPhone app with onboarding, prayer flow, and dashboard
- FamilyControls app picker and Screen Time authorization
- ManagedSettings shielding + unblock for a configured window
- DeviceActivity re-lock schedule after unlock window
- SwiftData local persistence for profile and prayer events
- Bundled prayer templates JSON and selection logic

## Non-Goals
- Accounts, cloud sync, LLM content, paywalls, push notifications
- iPad support, widgets, bypass modes

## Assumptions / Preconditions
- `com.apple.developer.family-controls` entitlement has been approved
- Development performed on a physical iPhone (Screen Time APIs)
- No network calls in MVP

## Steps
1. Initialize Xcode project for iOS 17+ SwiftUI app, add app group, Screen Time capabilities, and entitlement placeholders.
2. Add targets for `ShieldConfigurationExtension` and `DeviceActivityMonitor`, wire deep-link from shield to app, and set up ManagedSettings store.
3. Implement onboarding and profile setup (tradition, vibe, translation, unlock duration) and store in SwiftData.
4. Build prayer flow and template selection with bundled JSON (including fallback logic) and log `PrayerEvent` records.
5. Implement unlock logic: remove shields, start DeviceActivitySchedule, and re-apply shields on schedule end.
6. Add dashboard, settings, and simple history list; include manual test checklist and README.

## Progress
- [ ] (2026-01-30 12:02Z) Initialize Xcode project with required targets and entitlements
- [ ] (2026-01-30 12:02Z) Implement Screen Time authorization and app selection
- [ ] (2026-01-30 12:02Z) Implement onboarding/profile persistence
- [ ] (2026-01-30 12:02Z) Implement prayer flow + template selection + logging
- [ ] (2026-01-30 12:02Z) Implement unlock/re-lock flow with DeviceActivity
- [ ] (2026-01-30 12:02Z) Finish dashboard/settings, docs, and manual tests

## Validation
- Run the acceptance checklist from `SCOPE.md` on a physical device
- Verify offline-only behavior (no network usage)
- Verify relock works after app termination and device restart

## Risks
- Apple entitlement approval timeline
- Screen Time APIs require physical device; simulator coverage limited
- Shield deep-link reliability across iOS versions and device states
