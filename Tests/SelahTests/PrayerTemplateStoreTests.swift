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
}
