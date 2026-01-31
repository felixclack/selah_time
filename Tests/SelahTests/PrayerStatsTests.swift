import XCTest
@testable import SelahSim

final class PrayerStatsTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    }

    func testTodayCountCountsEventsFromToday() {
        let now = date("2026-01-30T12:00:00Z")
        let events = [
            date("2026-01-30T00:01:00Z"),
            date("2026-01-30T11:59:59Z"),
            date("2026-01-29T23:59:59Z")
        ]

        let count = PrayerStats.todayCount(eventDates: events, now: now, calendar: calendar)
        XCTAssertEqual(count, 2)
    }

    func testStreakCountsConsecutiveDays() {
        let now = date("2026-01-30T12:00:00Z")
        let events = [
            date("2026-01-30T08:00:00Z"),
            date("2026-01-29T09:00:00Z"),
            date("2026-01-28T10:00:00Z"),
            date("2026-01-26T10:00:00Z")
        ]

        let streak = PrayerStats.streakCount(eventDates: events, now: now, calendar: calendar)
        XCTAssertEqual(streak, 3)
    }

    func testStreakResetsWhenDayIsMissing() {
        let now = date("2026-01-30T12:00:00Z")
        let events = [
            date("2026-01-30T08:00:00Z"),
            date("2026-01-28T10:00:00Z")
        ]

        let streak = PrayerStats.streakCount(eventDates: events, now: now, calendar: calendar)
        XCTAssertEqual(streak, 1)
    }

    private func date(_ iso: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: iso) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: iso) ?? Date()
    }
}
