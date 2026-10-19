import SwiftUI
import SwiftData

struct DashboardView: View {
    @EnvironmentObject private var screenTimeManager: ScreenTimeManager
    @EnvironmentObject private var templateStore: PrayerTemplateStore
    @Query(sort: \PrayerEvent.timestamp, order: .reverse) private var events: [PrayerEvent]

    let profile: UserProfile
    @Binding var showPrayerFlow: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    statusCard
                    rhythmCard
                    verseCard
                    recentSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 40)
            }
            .background(SelahBackground())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(profile: profile)
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(SelahPalette.ink)
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            SelahEyebrow(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
            Text(greeting)
                .font(.selahDisplay(36))
                .foregroundStyle(SelahPalette.ink)
        }
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: return "Good morning."
        case 12..<17: return "Good afternoon."
        default: return "Good evening."
        }
    }

    // MARK: Status

    private var statusCard: some View {
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            if let remaining = screenTimeManager.timeRemaining() {
                unlockedCard(remaining: remaining)
            } else {
                restingCard
            }
        }
    }

    private var restingCard: some View {
        SelahCard(padding: 24) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 8) {
                    Image(systemName: "moon.stars")
                    SelahEyebrow("Apps resting", tint: SelahPalette.olive)
                }
                .foregroundStyle(SelahPalette.olive)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Pause before you scroll.")
                        .font(.selahTitle(26))
                        .foregroundStyle(SelahPalette.ink)
                    Text(hasSelection
                         ? "Pray or read for a moment, and your apps open for \(SelahFormat.minutes(profile.unlockDuration))."
                         : "Choose which apps should wait for a pause in Settings.")
                        .font(.selahBody(16))
                        .foregroundStyle(SelahPalette.inkSoft)
                }

                Button("Begin a pause") {
                    showPrayerFlow = true
                }
                .buttonStyle(SelahPrimaryButtonStyle())
            }
        }
    }

    private func unlockedCard(remaining: TimeInterval) -> some View {
        let total = max(TimeInterval(profile.unlockDuration), remaining)
        return SelahCard(padding: 24) {
            HStack(spacing: 22) {
                ZStack {
                    Circle()
                        .stroke(SelahPalette.hairline, lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: remaining / total)
                        .stroke(SelahPalette.clay, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: remaining)
                    Text(SelahFormat.countdown(remaining))
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .monospacedDigit()
                        .foregroundStyle(SelahPalette.ink)
                }
                .frame(width: 104, height: 104)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(Int((remaining / 60).rounded(.up))) minutes left")

                VStack(alignment: .leading, spacing: 10) {
                    SelahEyebrow("Apps open", tint: SelahPalette.clay)
                    Text("Use this time well.")
                        .font(.selahTitle(21))
                        .foregroundStyle(SelahPalette.ink)
                    Button {
                        screenTimeManager.endUnlock()
                    } label: {
                        Label("Rest them now", systemImage: "lock")
                            .font(.selahLabel(14))
                            .foregroundStyle(SelahPalette.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(SelahPalette.ink.opacity(0.06), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var hasSelection: Bool {
        !screenTimeManager.selection.applicationTokens.isEmpty
            || !screenTimeManager.selection.categoryTokens.isEmpty
    }

    // MARK: Rhythm

    private var rhythmCard: some View {
        SelahCard(padding: 22) {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .firstTextBaseline) {
                    stat(value: todayCount, label: todayCount == 1 ? "pause today" : "pauses today")
                    Spacer()
                    stat(value: streakCount, label: "day streak")
                }

                HStack(spacing: 0) {
                    let week = weekActivity
                    ForEach(week.indices, id: \.self) { index in
                        let entry = week[index]
                        let isToday = Calendar.current.isDateInToday(entry.day)
                        VStack(spacing: 8) {
                            Circle()
                                .fill(entry.active ? SelahPalette.clay : Color.clear)
                                .overlay(Circle().stroke(entry.active ? Color.clear : SelahPalette.hairline, lineWidth: 1.5))
                                .frame(width: 14, height: 14)
                            Text(entry.day.formatted(.dateTime.weekday(.narrow)))
                                .font(.selahLabel(12))
                                .foregroundStyle(isToday ? SelahPalette.ink : SelahPalette.inkSoft)
                                .fontWeight(isToday ? .bold : .medium)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(entry.day.formatted(.dateTime.weekday(.wide))), \(entry.active ? "paused" : "no pause")")
                    }
                }
            }
        }
    }

    private func stat(value: Int, label: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("\(value)")
                .font(.selahTitle(30))
                .foregroundStyle(SelahPalette.ink)
            Text(label)
                .font(.selahBody(15))
                .foregroundStyle(SelahPalette.inkSoft)
        }
    }

    // MARK: Verse

    @ViewBuilder
    private var verseCard: some View {
        if let verse = templateStore.verseOfTheDay() {
            VStack(alignment: .leading, spacing: 12) {
                SelahEyebrow("A word for today")
                Text(verse.verseText)
                    .font(.selahScripture(22))
                    .lineSpacing(5)
                    .foregroundStyle(SelahPalette.ink)
                if let reference = verse.verseReference {
                    Text(reference)
                        .font(.selahLabel(14))
                        .foregroundStyle(SelahPalette.clay)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: Recent

    @ViewBuilder
    private var recentSection: some View {
        if !events.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    SelahEyebrow("Recent pauses")
                    Spacer()
                    NavigationLink("See all") {
                        PrayerHistoryView()
                    }
                    .font(.selahLabel(14))
                    .foregroundStyle(SelahPalette.clay)
                }

                SelahCard(padding: 0) {
                    VStack(spacing: 0) {
                        ForEach(Array(events.prefix(3).enumerated()), id: \.element.id) { index, event in
                            if index > 0 {
                                Divider().overlay(SelahPalette.hairline).padding(.leading, 70)
                            }
                            PauseRow(event: event)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                    }
                }
            }
        }
    }

    // MARK: Stats

    private var todayCount: Int {
        PrayerStats.todayCount(events: events)
    }

    private var streakCount: Int {
        PrayerStats.streakCount(events: events)
    }

    private var weekActivity: [(day: Date, active: Bool)] {
        PrayerStats.weekActivity(events: events)
    }
}
