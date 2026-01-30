---
created: 2026-01-30
status: idea
tags: [product, ios, screen-time, faith, habits]
surface-when: [discussing-product, planning, building]
---

# Selah

*"Selah" — a Hebrew word appearing 74 times in the Psalms, meaning to pause and reflect.*

## Summary
An iPhone app that blocks selected apps using iOS Screen Time controls and requires a short prayer flow **every time** you want to unlock them. The shield itself becomes a prompt to pause.

- **Per-unlock prayer** (no bypass)
- **Default unlock window:** 10 minutes
- **Personalization:** tradition/denomination + vibe during onboarding tailors prayer templates
- **Offline-first:** no network calls in MVP

## Goal
Turn "reaching for distraction" into a deliberate pause with God.

**MVP success:**
- Pick apps to block
- Tapping a shielded app opens Selah's prayer flow
- Completing the prayer unlocks apps for 10 minutes
- Apps re-lock automatically

## Platform & tech
- iPhone only
- iOS 17+
- Swift + SwiftUI
- Frameworks:
  - **FamilyControls** — authorization + app picker UI
  - **ManagedSettings** — apply/remove shields
  - **DeviceActivity** — schedule re-lock via `DeviceActivityMonitor` extension
- Storage: SwiftData (local only for MVP)
- **Entitlement required:** `com.apple.developer.family-controls` — must apply via Apple Developer portal before development begins

## Architecture

### Shield interaction
When user taps a shielded app:
1. iOS shows the shield overlay (customizable via `ShieldConfigurationExtension`)
2. Shield displays Selah branding + "Pause to unlock" button
3. Button deep-links into Selah app → prayer flow
4. On completion, Selah removes shields for configured duration

### Re-lock mechanism
- `DeviceActivityMonitor` extension runs in background
- On unlock, schedule a `DeviceActivitySchedule` ending at unlock_time + duration
- When schedule ends, extension callback re-applies shields via `ManagedSettingsStore`
- Survives app termination and device restart

### Data model
```swift
@Model class PrayerEvent {
    var timestamp: Date
    var mood: String
    var templateId: String
    var tradition: String
    var vibe: String
    var unlockDuration: Int // seconds
}

@Model class UserProfile {
    var tradition: String // "catholic", "evangelical", etc.
    var vibe: String // "liturgical", "pastoral", "contemplative", etc.
    var bibleTranslation: String? // "ESV", "NIV", etc.
    var unlockDuration: Int // default 600 (10 min)
}
```

## UX

### Onboarding
1. **Welcome** — "Selah turns distraction into devotion" + concept explanation
2. **Screen Time authorization** — request FamilyControls access
   - If denied: explain why it's required, offer to retry, cannot proceed without it
3. **App selection** — `FamilyActivityPicker` for apps/categories to gate
4. **Profile setup:**
   - Tradition (Catholic / Orthodox / Mainline Protestant / Evangelical / Charismatic / Non-denominational / Other)
   - Vibe (Liturgical & formal / Warm & pastoral / Direct & practical / Contemplative & meditative)
   - Bible translation (optional: ESV / NIV / NKJV / NLT / KJV / NASB)
5. **Unlock duration** — slider or preset (5 / 10 / 15 / 30 min), default 10
6. **Ready** — shields activate, show dashboard

### Prayer flow (unlock)
1. **Mood check** — "How are you right now?" (Grateful / Anxious / Distracted / Tired / Seeking / Joyful)
2. **Prayer + Scripture** — display template based on tradition × vibe × mood
   - Short prayer (2-3 sentences)
   - Supporting verse
   - Moment to read/reflect (no timer, user proceeds when ready)
3. **"Amen"** — button to complete and unlock
4. **Confirmation** — "Apps unlocked for 10 minutes" + return to previous app or dashboard

### Dashboard
- **Primary CTA:** "Unlock apps" (or time remaining if active)
- **Today:** unlock count
- **Streak:** consecutive days with at least one prayer (see definition below)
- **Settings:** gear icon

### Settings
- Edit blocked apps
- Change tradition/vibe
- Adjust unlock duration
- View prayer history (simple list)
- Reset streak (hidden, requires confirmation)

## Prayer content

### Template structure
Each template has:
- `id`: unique identifier
- `tradition`: which tradition(s) it suits
- `vibe`: which vibe(s) it suits
- `moods`: which moods it addresses
- `prayer`: the prayer text (2-3 sentences)
- `verse`: scripture reference + text
- `translation`: Bible translation used

### MVP content requirements
- **Minimum 30 templates** covering the tradition × vibe × mood matrix
- Fallback "universal" templates for gaps
- All content bundled in app (JSON file)
- Source: public domain prayers, Psalms, or original compositions

### Example template
```json
{
  "id": "anxious-evangelical-pastoral-01",
  "tradition": ["evangelical", "charismatic"],
  "vibe": ["pastoral"],
  "moods": ["anxious", "distracted"],
  "prayer": "Lord, my heart is racing and my mind won't settle. I bring my anxiety to you. Help me remember that you hold all things, including this moment.",
  "verse": "Cast all your anxiety on him because he cares for you. — 1 Peter 5:7",
  "translation": "NIV"
}
```

## Edge cases

| Scenario | Behavior |
|----------|----------|
| User denies Screen Time authorization | Cannot proceed; explain requirement, offer retry |
| User closes app mid-prayer | Prayer not completed; shields remain; resume on next open |
| Phone restarts during unlock window | DeviceActivity extension re-applies shields on schedule end |
| User hasn't accessed blocked apps all day | Streak still counts if they completed any prayer that day |
| Unlock window active, user opens Selah | Show time remaining, no new prayer required |
| No template matches tradition/vibe/mood | Use "universal" fallback template |

## Streak definition
- Streak increments if **at least one prayer is completed** on a calendar day (device timezone)
- Streak resets if a day passes with zero completed prayers
- Opening the app without completing a prayer does not count
- Backdating is not allowed

## Out of scope (MVP)
- Subscriptions/paywalls
- LLM-generated prayers
- Accounts/cloud sync
- Push notifications
- Social/sharing features
- Emergency bypass mode
- iPad support
- Widgets

## Acceptance tests
1. Onboarding completes end-to-end on physical device
2. Selected apps show Selah shield overlay
3. Tapping shield opens Selah prayer flow
4. Completing prayer unlocks apps
5. Apps re-lock after configured duration (even if Selah not running)
6. Different tradition/vibe/mood combinations show different prayers
7. Works fully offline after initial install
8. Streak increments correctly across day boundaries
9. App survives force-quit and device restart without losing state

## Pre-development requirements
1. **Apply for entitlement:** Submit request for `com.apple.developer.family-controls` via Apple Developer portal. Explain use case clearly. This can take days/weeks.
2. **Provision prayer content:** Write or source minimum 30 prayer templates
3. **Design shield UI:** Custom `ShieldConfigurationExtension` appearance

## TestFlight plan
- Initial testers: personal use + 2-3 trusted friends from church
- Feedback focus: prayer content quality, unlock duration preferences, any shield reliability issues

## Agent build prompt
Build an iOS 17+ SwiftUI app called "Selah" that blocks selected apps using Screen Time (FamilyControls + ManagedSettings + DeviceActivity) and requires a prayer flow **every time** the user wants to unlock.

Key requirements:
- Custom `ShieldConfigurationExtension` that deep-links to Selah
- `DeviceActivityMonitor` extension for reliable re-lock after unlock window expires
- SwiftData for local persistence
- Onboarding captures tradition, vibe, and optional Bible translation
- 10-minute default unlock duration (configurable)
- Offline-only, no network calls
- No bypass mode

Deliver: Xcode project with app + extensions, README, prayer template JSON structure, and manual test checklist.
