import SwiftUI
import SwiftData

struct PrayerHistoryView: View {
    @Query(sort: \PrayerEvent.timestamp, order: .reverse) private var events: [PrayerEvent]

    var body: some View {
        Group {
            if events.isEmpty {
                ContentUnavailableView(
                    "No pauses yet",
                    systemImage: "leaf",
                    description: Text("Each time you pray or read before opening an app, it will appear here.")
                )
            } else {
                List {
                    ForEach(days, id: \.self) { day in
                        Section {
                            ForEach(eventsByDay[day] ?? []) { event in
                                PauseRow(event: event)
                                    .listRowBackground(SelahRowBackground())
                            }
                        } header: {
                            SelahEyebrow(title(for: day))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
        }
        .background(SelahBackground())
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var eventsByDay: [Date: [PrayerEvent]] {
        Dictionary(grouping: events) { Calendar.current.startOfDay(for: $0.timestamp) }
    }

    private var days: [Date] {
        eventsByDay.keys.sorted(by: >)
    }

    private func title(for day: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(day) { return "Today" }
        if calendar.isDateInYesterday(day) { return "Yesterday" }
        return day.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }
}

/// One completed pause: what it was and when.
struct PauseRow: View {
    @EnvironmentObject private var templateStore: PrayerTemplateStore
    @EnvironmentObject private var readingStore: ReadingStore

    let event: PrayerEvent

    var body: some View {
        HStack(spacing: 14) {
            SelahGlyph(systemName: glyph, tint: event.pauseKind == .reading ? SelahPalette.olive : SelahPalette.clay, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.selahHeading(16))
                    .foregroundStyle(SelahPalette.ink)
                if let detail {
                    Text(detail)
                        .font(.selahBody(14))
                        .foregroundStyle(SelahPalette.inkSoft)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Text(event.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.selahLabel(13))
                .foregroundStyle(SelahPalette.inkSoft)
        }
        .accessibilityElement(children: .combine)
    }

    private var mood: PrayerMood? {
        PrayerMood(rawValue: event.mood)
    }

    private var glyph: String {
        switch event.pauseKind {
        case .reading: return PauseKind.reading.systemImage
        case .prayer: return mood?.systemImage ?? PauseKind.prayer.systemImage
        }
    }

    private var title: String {
        switch event.pauseKind {
        case .reading:
            return readingStore.reading(id: event.templateId)?.title ?? "Scripture reading"
        case .prayer:
            return mood.map { "Prayed · \($0.displayName)" } ?? "Prayed"
        }
    }

    private var detail: String? {
        switch event.pauseKind {
        case .reading:
            return readingStore.reading(id: event.templateId)?.reference
        case .prayer:
            return templateStore.templates.first { $0.id == event.templateId }?.verseReference
        }
    }
}
