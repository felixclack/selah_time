import XCTest
@testable import SelahSim

final class PrayerTemplateStoreTests: XCTestCase {
    func testExactMatchIsReturned() {
        let templates = [
            PrayerTemplate(
                id: "exact",
                tradition: ["evangelical"],
                vibe: ["pastoral"],
                moods: ["grateful"],
                prayer: "test",
                verse: "test",
                translation: "KJV"
            )
        ]

        let store = PrayerTemplateStore(templates: templates)
        let profile = UserProfile(tradition: "evangelical", vibe: "pastoral", bibleTranslation: nil, unlockDuration: 600)

        let template = store.template(for: profile, mood: .grateful)
        XCTAssertEqual(template?.id, "exact")
    }

    func testFallbackMatchesUniversal() {
        let templates = [
            PrayerTemplate(
                id: "universal",
                tradition: ["universal"],
                vibe: ["universal"],
                moods: ["anxious"],
                prayer: "test",
                verse: "test",
                translation: "KJV"
            )
        ]

        let store = PrayerTemplateStore(templates: templates)
        let profile = UserProfile(tradition: "orthodox", vibe: "contemplative", bibleTranslation: nil, unlockDuration: 600)

        let template = store.template(for: profile, mood: .anxious)
        XCTAssertEqual(template?.id, "universal")
    }

    func testJSONTemplatesDecode() throws {
        let bundle = Bundle(for: PrayerTemplateStoreTests.self)
        let url = bundle.url(forResource: "PrayerTemplates", withExtension: "json")
            ?? Bundle.main.url(forResource: "PrayerTemplates", withExtension: "json")
        guard let url else {
            XCTFail("PrayerTemplates.json not found in test or app bundle")
            return
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([PrayerTemplate].self, from: data)
        XCTAssertFalse(decoded.isEmpty)
    }

    func testJSONReadingsDecode() throws {
        guard let url = Bundle.main.url(forResource: "Readings", withExtension: "json") else {
            XCTFail("Readings.json not found in app bundle")
            return
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([Reading].self, from: data)
        XCTAssertFalse(decoded.isEmpty)
        XCTAssertEqual(Set(decoded.map(\.id)).count, decoded.count)
    }

    func testReadingStoreAdvancesInOrderAndWraps() throws {
        let suiteName = "ReadingStoreTests-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let readings = ["a", "b"].map {
            Reading(id: $0, reference: $0, title: $0, verses: [], reflection: "", translation: "KJV")
        }
        let store = ReadingStore(readings: readings, defaults: defaults)

        XCTAssertEqual(store.nextReading?.id, "a")
        store.markCompleted(readings[0])
        XCTAssertEqual(store.nextReading?.id, "b")
        store.markCompleted(readings[0])
        XCTAssertEqual(store.nextReading?.id, "b", "Completing a passage that isn't next should not advance")
        store.markCompleted(readings[1])
        XCTAssertEqual(store.nextReading?.id, "a")
        store.resetProgress()
        XCTAssertEqual(store.completedCount, 0)
    }

    func testVerseOfTheDayIsStableForADay() {
        let templates = ["x", "y", "z"].map {
            PrayerTemplate(id: $0, tradition: ["universal"], vibe: ["universal"], moods: ["grateful"], prayer: "", verse: "\($0) — Ref", translation: "KJV")
        }
        let store = PrayerTemplateStore(templates: templates)
        let day = Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 1_800_000_000))
        let morning = day.addingTimeInterval(8 * 3600)
        let evening = day.addingTimeInterval(20 * 3600)
        XCTAssertEqual(store.verseOfTheDay(for: morning)?.id, store.verseOfTheDay(for: evening)?.id)
        XCTAssertEqual(templates[0].verseText, "x")
        XCTAssertEqual(templates[0].verseReference, "Ref")
    }
}
