import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

@MainActor
final class ScreenTimeManager: ObservableObject {
    @Published var selection: FamilyActivitySelection {
        didSet {
            persistSelection(selection)
            if !isUnlockActive {
                applyShielding()
            }
        }
    }
    @Published var authorizationStatus: AuthorizationStatus
    @Published var unlockEndDate: Date?

    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()
    private let defaults = UserDefaults(suiteName: AppConstants.appGroupId)

    init() {
        if let saved = ScreenTimeManager.loadSelection() {
            selection = saved
        } else {
            selection = FamilyActivitySelection()
        }
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        unlockEndDate = defaults?.object(forKey: AppConstants.unlockEndKey) as? Date
    }

    func bootstrap() async {
        refreshAuthorizationStatus()
        await refreshShieldingIfNeeded()
    }

    func refreshAuthorizationStatus() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }

    func requestAuthorization() async -> Bool {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            refreshAuthorizationStatus()
            return authorizationStatus == .approved
        } catch {
            refreshAuthorizationStatus()
            return false
        }
    }

    func updateSelection(_ newSelection: FamilyActivitySelection) {
        selection = newSelection
        if !isUnlockActive {
            applyShielding()
        }
    }

    func applyShielding() {
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
    }

    func clearShielding() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    func unlockApps(duration: TimeInterval) {
        let endDate = Date().addingTimeInterval(duration)
        unlockEndDate = endDate
        defaults?.set(endDate, forKey: AppConstants.unlockEndKey)
        clearShielding()
        scheduleRelock(until: endDate)
    }

    func endUnlock() {
        unlockEndDate = nil
        defaults?.removeObject(forKey: AppConstants.unlockEndKey)
        applyShielding()
    }

    func timeRemaining() -> TimeInterval? {
        guard let endDate = unlockEndDate else { return nil }
        let remaining = endDate.timeIntervalSinceNow
        return remaining > 0 ? remaining : nil
    }

    var isUnlockActive: Bool {
        guard let endDate = unlockEndDate else { return false }
        return endDate.timeIntervalSinceNow > 0
    }

    func refreshShieldingIfNeeded() async {
        if isUnlockActive {
            scheduleRelock(until: unlockEndDate ?? Date())
        } else {
            endUnlock()
        }
    }

    private func scheduleRelock(until endDate: Date) {
        let startDate = Date()
        let schedule = DeviceActivitySchedule(
            intervalStart: Calendar.current.dateComponents([.hour, .minute, .second], from: startDate),
            intervalEnd: Calendar.current.dateComponents([.hour, .minute, .second], from: endDate),
            repeats: false
        )

        do {
            center.stopMonitoring([.unlockWindow])
            try center.startMonitoring(.unlockWindow, during: schedule)
        } catch {
            // If scheduling fails, re-apply shields immediately.
            applyShielding()
        }
    }

    private func persistSelection(_ selection: FamilyActivitySelection) {
        guard let data = try? PropertyListEncoder().encode(selection) else { return }
        defaults?.set(data, forKey: AppConstants.selectionKey)
        NotificationCenter.default.post(name: .selectionDidChange, object: nil)
    }

    private static func loadSelection() -> FamilyActivitySelection? {
        let defaults = UserDefaults(suiteName: AppConstants.appGroupId)
        guard let data = defaults?.data(forKey: AppConstants.selectionKey) else { return nil }
        return try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
    }
}

extension DeviceActivityName {
    static let unlockWindow = DeviceActivityName("unlock-window")
}
