import Foundation

struct PrayerTemplate: Codable, Identifiable, Hashable {
    let id: String
    let tradition: [String]
    let vibe: [String]
    let moods: [String]
    let prayer: String
    let verse: String
    let translation: String
}

enum PrayerMood: String, CaseIterable, Identifiable {
    case grateful
    case anxious
    case distracted
    case tired
    case seeking
    case joyful

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var systemImage: String {
        switch self {
        case .grateful: return "heart"
        case .anxious: return "wind"
        case .distracted: return "circle.dashed"
        case .tired: return "moon.zzz"
        case .seeking: return "sparkle.magnifyingglass"
        case .joyful: return "sun.max"
        }
    }
}

/// The two ways to spend a pause.
enum PauseKind: String, CaseIterable, Identifiable {
    case prayer
    case reading

    var id: String { rawValue }

    var title: String {
        switch self {
        case .prayer: return "Pray"
        case .reading: return "Read Scripture"
        }
    }

    var subtitle: String {
        switch self {
        case .prayer: return "A short prayer for how you are right now"
        case .reading: return "The next passage in your reading"
        }
    }

    var systemImage: String {
        switch self {
        case .prayer: return "hands.and.sparkles"
        case .reading: return "book"
        }
    }
}

/// A short Scripture passage read in order, one per reading pause.
struct Reading: Codable, Identifiable, Hashable {
    struct Verse: Codable, Hashable {
        let number: Int
        let text: String
    }

    let id: String
    let reference: String
    let title: String
    let verses: [Verse]
    let reflection: String
    let translation: String
}

enum BibleTranslation {
    static let options = ["ESV", "NIV", "NKJV", "NLT", "KJV", "NASB", "CSB"]
}

enum Tradition: String, CaseIterable, Identifiable {
    case catholic
    case orthodox
    case mainlineProtestant
    case evangelical
    case charismatic
    case nonDenominational
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mainlineProtestant:
            return "Mainline Protestant"
        case .nonDenominational:
            return "Non-denominational"
        default:
            return rawValue.capitalized
        }
    }
}

enum Vibe: String, CaseIterable, Identifiable {
    case liturgical
    case pastoral
    case practical
    case contemplative

    var id: String { rawValue }

    var detail: String {
        switch self {
        case .liturgical:
            return "Ordered words with the cadence of the prayer book"
        case .pastoral:
            return "Gentle and personal, like a friend praying with you"
        case .practical:
            return "Plain, short, and to the point"
        case .contemplative:
            return "Spacious and slow, with room for silence"
        }
    }

    var displayName: String {
        switch self {
        case .liturgical:
            return "Liturgical & Formal"
        case .pastoral:
            return "Warm & Pastoral"
        case .practical:
            return "Direct & Practical"
        case .contemplative:
            return "Contemplative & Meditative"
        }
    }
}

extension PrayerTemplate {
    /// Verse text without the trailing "— Reference".
    var verseText: String {
        verse.components(separatedBy: " — ").first ?? verse
    }

    /// The reference after the em dash, e.g. "Psalm 46:10".
    var verseReference: String? {
        let parts = verse.components(separatedBy: " — ")
        return parts.count > 1 ? parts.last : nil
    }
}
