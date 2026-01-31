import SwiftUI
import SwiftData

struct DashboardView: View {
    @EnvironmentObject private var screenTimeManager: ScreenTimeManager
    @Query(sort: \PrayerEvent.timestamp, order: .reverse) private var events: [PrayerEvent]

    let profile: UserProfile
    @Binding var showPrayerFlow: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                SelahBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        header
                        unlockCard

                        HStack(spacing: 16) {
                            statCard(title: "Today", value: "\(todayCount)", systemImage: "sparkles", tint: SelahPalette.lemon)
                            statCard(title: "Streak", value: "\(streakCount)", systemImage: "flame.fill", tint: SelahPalette.accent)
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(20)
                }
            }
            .toolbar {
                NavigationLink {
                    SettingsView(profile: profile)
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.headline)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            SelahTag("Daily pause", tint: SelahPalette.lilac)
            Text("Selah Time")
                .font(.selahTitle(34))
                .foregroundStyle(SelahPalette.ink)
            Text("Pause and pray before you unlock.")
                .font(.selahBody(16))
                .foregroundStyle(SelahPalette.ink.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var unlockCard: some View {
        SelahCard {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(SelahPalette.lemon.opacity(0.6))
                        .frame(width: 44, height: 44)
                    Image(systemName: "lock.shield")
                        .font(.headline)
                        .foregroundStyle(SelahPalette.ink)
                }

                VStack(alignment: .leading, spacing: 10) {
                    if let remaining = screenTimeManager.timeRemaining() {
                        Text("Apps unlocked")
                            .font(.selahHeading(18))
                        Text("Time remaining: \(formatTime(remaining))")
                            .font(.selahTitle(22))
                    } else {
                        Text("Ready to unlock?")
                            .font(.selahHeading(18))
                        Button("Unlock apps") {
                            showPrayerFlow = true
                        }
                        .buttonStyle(SelahPrimaryButtonStyle())
                    }
                }
            }
        }
    }

    private func statCard(title: String, value: String, systemImage: String, tint: Color) -> some View {
        SelahCard {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.22))
                        .frame(width: 38, height: 38)
                    Image(systemName: systemImage)
                        .font(.headline)
                        .foregroundStyle(SelahPalette.ink)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.selahLabel(13))
                        .foregroundStyle(SelahPalette.ink.opacity(0.6))
                    Text(value)
                        .font(.selahHeading(20))
                        .foregroundStyle(SelahPalette.ink)
                }
            }
        }
    }

    private var todayCount: Int {
        PrayerStats.todayCount(events: events)
    }

    private var streakCount: Int {
        PrayerStats.streakCount(events: events)
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
