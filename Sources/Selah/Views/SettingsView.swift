import SwiftUI
import SwiftData
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject private var screenTimeManager: ScreenTimeManager
    @EnvironmentObject private var readingStore: ReadingStore
    @Environment(\.modelContext) private var modelContext

    @Bindable var profile: UserProfile

    @State private var showAppPicker = false
    @State private var confirmReadingReset = false

    static let durationOptions = [5, 10, 15, 30]

    var body: some View {
        Form {
            Section {
                Button {
                    showAppPicker = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Paused apps")
                                .foregroundStyle(SelahPalette.ink)
                            Text(screenTimeManager.selection.summary)
                                .font(.selahBody(14))
                                .foregroundStyle(SelahPalette.inkSoft)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(SelahPalette.inkSoft)
                    }
                }
            } header: {
                SelahEyebrow("Apps")
            } footer: {
                Text("These apps rest behind a Selah screen until you pause.")
            }
            .listRowBackground(SelahRowBackground())

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Apps stay open for \(SelahFormat.minutes(profile.unlockDuration)) after each pause.")
                        .foregroundStyle(SelahPalette.ink)
                    HStack(spacing: 8) {
                        ForEach(Self.durationOptions, id: \.self) { minutes in
                            SelahPill(title: "\(minutes) min", isSelected: profile.unlockDuration == minutes * 60) {
                                profile.unlockDuration = minutes * 60
                            }
                        }
                    }
                }
                .padding(.vertical, 6)
            } header: {
                SelahEyebrow("Unlock window")
            }
            .listRowBackground(SelahRowBackground())

            Section {
                Picker("Tradition", selection: $profile.tradition) {
                    ForEach(Tradition.allCases) { tradition in
                        Text(tradition.displayName).tag(tradition.rawValue)
                    }
                }

                Picker("Prayer voice", selection: $profile.vibe) {
                    ForEach(Vibe.allCases) { vibe in
                        Text(vibe.displayName).tag(vibe.rawValue)
                    }
                }

                Picker("Bible translation", selection: $profile.bibleTranslation) {
                    Text("No preference").tag(String?.none)
                    ForEach(BibleTranslation.options, id: \.self) { translation in
                        Text(translation).tag(Optional(translation))
                    }
                }
            } header: {
                SelahEyebrow("Prayer")
            }
            .listRowBackground(SelahRowBackground())
            .tint(SelahPalette.clay)

            Section {
                HStack {
                    Text("Passages read")
                    Spacer()
                    Text("\(readingStore.completedCount)")
                        .foregroundStyle(SelahPalette.inkSoft)
                }
                Button("Start readings from the beginning") {
                    confirmReadingReset = true
                }
                .foregroundStyle(SelahPalette.clay)
                .disabled(readingStore.completedCount == 0)
            } header: {
                SelahEyebrow("Scripture reading")
            } footer: {
                Text("Readings go in order through \(readingStore.readings.count) short passages, then begin again.")
            }
            .listRowBackground(SelahRowBackground())

            Section {
                NavigationLink("Pause history") {
                    PrayerHistoryView()
                }
            }
            .listRowBackground(SelahRowBackground())

            Section {
                EmptyView()
            } footer: {
                Text("“Selah” appears 74 times in the Psalms. It's often read as a call to pause and reflect.")
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .font(.selahBody(16))
        .foregroundStyle(SelahPalette.ink)
        .scrollContentBackground(.hidden)
        .background(SelahBackground())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .familyActivityPicker(isPresented: $showAppPicker, selection: $screenTimeManager.selection)
        .confirmationDialog("Start readings over?", isPresented: $confirmReadingReset, titleVisibility: .visible) {
            Button("Start over", role: .destructive) {
                readingStore.resetProgress()
            }
        } message: {
            Text("Your next reading pause will begin with the first passage.")
        }
        .onDisappear {
            try? modelContext.save()
        }
    }
}

extension FamilyActivitySelection {
    /// e.g. "3 apps · 1 category", or a prompt when nothing is chosen.
    var summary: String {
        let apps = applicationTokens.count
        let categories = categoryTokens.count
        var parts: [String] = []
        if apps > 0 { parts.append(apps == 1 ? "1 app" : "\(apps) apps") }
        if categories > 0 { parts.append(categories == 1 ? "1 category" : "\(categories) categories") }
        return parts.isEmpty ? "None chosen yet" : parts.joined(separator: " · ")
    }
}
