import Foundation

enum AppConstants {
    static let appGroupId = SharedConstants.appGroupId
    static let selectionKey = SharedConstants.selectionKey
    static let unlockEndKey = SharedConstants.unlockEndKey
}

extension Notification.Name {
    static let selectionDidChange = Notification.Name("selah.selectionDidChange")
}
