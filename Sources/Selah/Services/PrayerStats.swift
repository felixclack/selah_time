import Foundation

enum PrayerStats {
    static func todayCount(eventDates: [Date], now: Date = Date(), calendar: Calendar = .current) -> Int {
        let startOfDay = calendar.startOfDay(for: now)
        return eventDates.filter { $0 >= startOfDay }.count
    }

    static func streakCount(eventDates: [Date], now: Date = Date(), calendar: Calendar = .current) -> Int {
        let daysWithEvents = Set(eventDates.map { calendar.startOfDay(for: $0) })
        var count = 0
        var day = calendar.startOfDay(for: now)

        while daysWithEvents.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }

        return count
    }

    static func todayCount(events: [PrayerEvent], now: Date = Date(), calendar: Calendar = .current) -> Int {
        todayCount(eventDates: events.map { $0.timestamp }, now: now, calendar: calendar)
    }

    static func streakCount(events: [PrayerEvent], now: Date = Date(), calendar: Calendar = .current) -> Int {
        streakCount(eventDates: events.map { $0.timestamp }, now: now, calendar: calendar)
    }

    /// The last seven days ending today, oldest first, with whether each had a completed pause.
    static func weekActivity(eventDates: [Date], now: Date = Date(), calendar: Calendar = .current) -> [(day: Date, active: Bool)] {
        let daysWithEvents = Set(eventDates.map { calendar.startOfDay(for: $0) })
        let today = calendar.startOfDay(for: now)
        return (0..<7).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return (day: day, active: daysWithEvents.contains(day))
        }
    }

    static func weekActivity(events: [PrayerEvent], now: Date = Date(), calendar: Calendar = .current) -> [(day: Date, active: Bool)] {
        weekActivity(eventDates: events.map { $0.timestamp }, now: now, calendar: calendar)
    }
}
