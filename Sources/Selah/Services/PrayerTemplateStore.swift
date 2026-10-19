import Foundation

final class PrayerTemplateStore: ObservableObject {
    @Published private(set) var templates: [PrayerTemplate] = []

    init(templates: [PrayerTemplate]? = nil) {
        if let templates {
            self.templates = templates
        } else {
            loadTemplates()
        }
    }

    func template(for profile: UserProfile, mood: PrayerMood) -> PrayerTemplate? {
        let tradition = profile.tradition.lowercased()
        let vibe = profile.vibe.lowercased()
        let moodValue = mood.rawValue.lowercased()

        let exactMatches = templates.filter {
            $0.tradition.map { $0.lowercased() }.contains(tradition)
                && $0.vibe.map { $0.lowercased() }.contains(vibe)
                && $0.moods.map { $0.lowercased() }.contains(moodValue)
        }

        if let match = exactMatches.randomElement() {
            return match
        }

        let fallbackMatches = templates.filter {
            $0.tradition.contains("universal") || $0.vibe.contains("universal")
        }.filter {
            $0.moods.map { $0.lowercased() }.contains(moodValue)
        }

        return fallbackMatches.randomElement() ?? templates.first
    }

    private func loadTemplates() {
        guard let url = Bundle.main.url(forResource: "PrayerTemplates", withExtension: "json") else {
            templates = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([PrayerTemplate].self, from: data)
            templates = decoded
        } catch {
            templates = []
        }
    }
}

extension PrayerTemplateStore {
    /// A stable verse for the given day, drawn from the bundled templates.
    func verseOfTheDay(for date: Date = Date(), calendar: Calendar = .current) -> PrayerTemplate? {
        let verses = Dictionary(grouping: templates, by: \.verse).values.compactMap(\.first).sorted { $0.id < $1.id }
        guard !verses.isEmpty else { return nil }
        let day = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        return verses[day % verses.count]
    }
}

/// Bundled Scripture passages, read in order across reading pauses.
final class ReadingStore: ObservableObject {
    static let progressKey = "selah.readingIndex"

    @Published private(set) var readings: [Reading] = []
    private let defaults: UserDefaults

    init(readings: [Reading]? = nil, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let readings {
            self.readings = readings
        } else {
            loadReadings()
        }
    }

    /// Number of passages completed, which is also the index of the next one.
    var completedCount: Int {
        defaults.integer(forKey: Self.progressKey)
    }

    var nextReading: Reading? {
        guard !readings.isEmpty else { return nil }
        return readings[completedCount % readings.count]
    }

    func reading(id: String) -> Reading? {
        readings.first { $0.id == id }
    }

    func markCompleted(_ reading: Reading) {
        guard reading.id == nextReading?.id else { return }
        defaults.set(completedCount + 1, forKey: Self.progressKey)
        objectWillChange.send()
    }

    func resetProgress() {
        defaults.removeObject(forKey: Self.progressKey)
        objectWillChange.send()
    }

    private func loadReadings() {
        guard let url = Bundle.main.url(forResource: "Readings", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Reading].self, from: data) else {
            readings = []
            return
        }
        readings = decoded
    }
}
