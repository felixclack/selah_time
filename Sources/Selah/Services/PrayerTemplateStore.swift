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
