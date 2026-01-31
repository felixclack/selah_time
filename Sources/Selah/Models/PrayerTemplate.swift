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
