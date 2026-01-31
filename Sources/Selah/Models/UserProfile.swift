import Foundation
import SwiftData

@Model
final class UserProfile {
    var tradition: String
    var vibe: String
    var bibleTranslation: String?
    var unlockDuration: Int

    init(tradition: String, vibe: String, bibleTranslation: String?, unlockDuration: Int) {
        self.tradition = tradition
        self.vibe = vibe
        self.bibleTranslation = bibleTranslation
        self.unlockDuration = unlockDuration
    }
}
