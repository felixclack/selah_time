import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore()

    override func intervalDidEnd(for activity: DeviceActivityName) {
        applyShielding()
    }

    private func applyShielding() {
        guard let selection = loadSelection() else {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            return
        }
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        let defaults = UserDefaults(suiteName: SharedConstants.appGroupId)
        defaults?.removeObject(forKey: SharedConstants.unlockEndKey)
    }

    private func loadSelection() -> FamilyActivitySelection? {
        let defaults = UserDefaults(suiteName: SharedConstants.appGroupId)
        guard let data = defaults?.data(forKey: SharedConstants.selectionKey) else { return nil }
        return try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
    }
}

extension DeviceActivityName {
    static let unlockWindow = DeviceActivityName("unlock-window")
}
