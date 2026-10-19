import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var screenTimeManager: ScreenTimeManager
    @Query private var profiles: [UserProfile]
    @State private var showPrayerFlow = false

    var body: some View {
        Group {
            if let profile = profiles.first {
                DashboardView(profile: profile, showPrayerFlow: $showPrayerFlow)
            } else {
                OnboardingFlowView()
            }
        }
        .tint(SelahPalette.clay)
        .onOpenURL { url in
            // While apps are already open, a new pause isn't needed; the dashboard shows the time left.
            guard url.scheme == "selah", !profiles.isEmpty, !screenTimeManager.isUnlockActive else { return }
            showPrayerFlow = true
        }
        .fullScreenCover(isPresented: $showPrayerFlow) {
            if let profile = profiles.first {
                PrayerFlowView(profile: profile) {
                    showPrayerFlow = false
                }
            } else {
                EmptyView()
            }
        }
        .onAppear {
            screenTimeManager.refreshAuthorizationStatus()
        }
    }
}
