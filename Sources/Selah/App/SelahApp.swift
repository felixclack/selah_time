import SwiftUI
import SwiftData

@main
struct SelahApp: App {
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @StateObject private var templateStore = PrayerTemplateStore()

    private var container: ModelContainer = {
        let schema = Schema([UserProfile.self, PrayerEvent.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(screenTimeManager)
                .environmentObject(templateStore)
                .task {
                    await screenTimeManager.bootstrap()
                }
        }
        .modelContainer(container)
    }
}
