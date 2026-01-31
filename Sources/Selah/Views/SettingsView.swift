import SwiftUI
import SwiftData
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject private var screenTimeManager: ScreenTimeManager
    @Environment(\.modelContext) private var modelContext

    @Bindable var profile: UserProfile

    @State private var showTranslationPicker = false

    var body: some View {
        ZStack {
            SelahBackground()

            Form {
                Section {
                    FamilyActivityPicker(selection: $screenTimeManager.selection)
                        .frame(minHeight: 220)
                } header: {
                    Text("Blocked Apps")
                        .font(.selahLabel(12))
                        .foregroundStyle(SelahPalette.ink.opacity(0.7))
                }
                .listRowBackground(SelahRowBackground())

                Section {
                    Picker("Tradition", selection: $profile.tradition) {
                        ForEach(Tradition.allCases) { tradition in
                            Text(tradition.displayName).tag(tradition.rawValue)
                        }
                    }

                    Picker("Vibe", selection: $profile.vibe) {
                        ForEach(Vibe.allCases) { vibe in
                            Text(vibe.displayName).tag(vibe.rawValue)
                        }
                    }

                    Toggle("Set a Bible translation", isOn: $showTranslationPicker)
                    if showTranslationPicker {
                        TextField("Translation", text: Binding(
                            get: { profile.bibleTranslation ?? "" },
                            set: { profile.bibleTranslation = $0.isEmpty ? nil : $0 }
                        ))
                    }
                } header: {
                    Text("Prayer Preferences")
                        .font(.selahLabel(12))
                        .foregroundStyle(SelahPalette.ink.opacity(0.7))
                }
                .listRowBackground(SelahRowBackground())

                Section {
                    Stepper(value: Binding(
                        get: { profile.unlockDuration / 60 },
                        set: { profile.unlockDuration = $0 * 60 }
                    ), in: 5...30, step: 5) {
                        Text("\(profile.unlockDuration / 60) minutes")
                    }
                } header: {
                    Text("Unlock Duration")
                        .font(.selahLabel(12))
                        .foregroundStyle(SelahPalette.ink.opacity(0.7))
                }
                .listRowBackground(SelahRowBackground())

                Section {
                    NavigationLink("View history") {
                        PrayerHistoryView()
                    }
                } header: {
                    Text("Prayer History")
                        .font(.selahLabel(12))
                        .foregroundStyle(SelahPalette.ink.opacity(0.7))
                }
                .listRowBackground(SelahRowBackground())
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Settings")
        .onChange(of: screenTimeManager.selection) { _ in
            screenTimeManager.applyShielding()
        }
        .onChange(of: showTranslationPicker) { isOn in
            if !isOn {
                profile.bibleTranslation = nil
            }
        }
        .onAppear {
            showTranslationPicker = profile.bibleTranslation != nil
        }
        .onDisappear {
            try? modelContext.save()
        }
    }
}
