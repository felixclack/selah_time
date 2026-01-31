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

    init(timestamp: Date, mood: String, templateId: String, tradition: String, vibe: String, unlockDuration: Int) {
        self.timestamp = timestamp
        self.mood = mood
        self.templateId = templateId
        self.tradition = tradition
        self.vibe = vibe
        self.unlockDuration = unlockDuration
    }
}
