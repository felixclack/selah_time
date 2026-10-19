import Foundation
import SwiftData

@Model
final class PrayerEvent {
    var timestamp: Date
    var mood: String
    var templateId: String
    var tradition: String
    var vibe: String
    var unlockDuration: Int
    /// `PauseKind` raw value. Optional so stores created before readings existed migrate cleanly; nil means prayer.
    var kind: String?

    init(timestamp: Date, mood: String, templateId: String, tradition: String, vibe: String, unlockDuration: Int, kind: PauseKind = .prayer) {
        self.timestamp = timestamp
        self.mood = mood
        self.templateId = templateId
        self.tradition = tradition
        self.vibe = vibe
        self.unlockDuration = unlockDuration
        self.kind = kind.rawValue
    }

    var pauseKind: PauseKind {
        kind.flatMap(PauseKind.init(rawValue:)) ?? .prayer
    }
}
