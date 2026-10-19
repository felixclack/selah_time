# Manual Test Checklist

Use a physical iPhone running iOS 17+.

## Onboarding
- [ ] Welcome and "How it works" pages load; progress bar advances.
- [ ] "Allow Screen Time access" requests authorization and advances when approved.
- [ ] If denied, the button reads "Try again" and onboarding cannot proceed.
- [ ] "Choose apps" opens the system picker; summary shows the app/category count.
- [ ] Tradition, prayer voice, and translation can be set.
- [ ] Unlock duration can be set (5 / 10 / 15 / 30 min).
- [ ] "Begin" applies shields to selected apps and shows the home screen.

## Shield + Pause Flow
- [ ] Opening a shielded app shows the Selah shield (warm paper colors, light and dark).
- [ ] "Begin a pause" (or a `selah://` link) opens the pause.
- [ ] Breathing screen shows for ~4 seconds before "Pray" and "Read Scripture" appear.
- [ ] Pray: mood selection displays scripture + prayer; "Amen" unlocks apps and shows "Go in peace."
- [ ] Read: passage shows; "I've read it" enables only after scrolling to the end; completing unlocks apps.
- [ ] The next reading pause shows the following passage.
- [ ] "Not now" closes the pause without unlocking.

## Unlock Window
- [ ] Apps stay unlocked for the configured duration.
- [ ] Apps re-lock after the duration expires (even if Selah is backgrounded).
- [ ] Device restart during unlock window still re-locks when time ends.

## Home + Settings
- [ ] While unlocked, home shows a live countdown ring; "Rest them now" re-locks apps.
- [ ] Home shows pauses today, streak, and this week's dots.
- [ ] Home shows a word for today and the three most recent pauses.
- [ ] Settings allows editing paused apps, unlock window, tradition, voice, translation.
- [ ] Settings can restart the reading plan.
- [ ] History groups pauses by day and shows prayers and readings.

## Offline
- [ ] App functions fully with no network connectivity.
