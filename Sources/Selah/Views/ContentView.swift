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
        .tint(SelahPalette.accent)
        .onOpenURL { url in
            guard url.scheme == "selah" else { return }
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
