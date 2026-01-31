import SwiftUI
import SwiftData

struct PrayerFlowView: View {
    @EnvironmentObject private var screenTimeManager: ScreenTimeManager
    @EnvironmentObject private var templateStore: PrayerTemplateStore
    @Environment(\.modelContext) private var modelContext

    let profile: UserProfile
    var onComplete: () -> Void

    @State private var step: Step = .mood
    @State private var selectedMood: PrayerMood?
    @State private var selectedTemplate: PrayerTemplate?

    enum Step {
        case mood
        case prayer
        case done
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SelahBackground()

                VStack(spacing: 20) {
                    switch step {
                    case .mood:
                        moodStep
                    case .prayer:
                        prayerStep
                    case .done:
                        doneStep
                    }

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Pause to Pray")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Close") {
                    onComplete()
                }
                .buttonStyle(SelahGhostButtonStyle())
            }
        }
    }

    private var moodStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            SelahTag("Check in", tint: SelahPalette.lemon)
            Text("How are you right now?")
                .font(.selahHeading(24))

            ForEach(PrayerMood.allCases) { mood in
                Button {
                    selectedMood = mood
                    selectedTemplate = templateStore.template(for: profile, mood: mood)
                    step = .prayer
                } label: {
                    HStack {
                        Text(mood.displayName)
                            .font(.selahBody(16))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(SelahSoftButtonStyle(tint: moodTint(mood)))
            }
        }
    }

    private var prayerStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let template = selectedTemplate, let mood = selectedMood {
                SelahCard {
                    VStack(alignment: .leading, spacing: 12) {
                        SelahTag("Prayer", tint: moodTint(mood))
                        Text(template.prayer)
                            .font(.selahBody(17))
                            .foregroundStyle(SelahPalette.ink)
                    }
                }

                SelahCard {
                    VStack(alignment: .leading, spacing: 12) {
                        SelahTag("Scripture", tint: SelahPalette.sky)
                        Text(template.verse)
                            .font(.selahBody(16))
                            .foregroundStyle(SelahPalette.ink)
                        Text(template.translation)
                            .font(.selahLabel(12))
                            .foregroundStyle(SelahPalette.ink.opacity(0.6))
                    }
                }

                Button("Amen") {
                    completePrayer(mood: mood, template: template)
                    step = .done
                }
                .buttonStyle(SelahPrimaryButtonStyle())
            } else {
                Text("Loading prayer...")
            }
        }
    }

    private var doneStep: some View {
        VStack(spacing: 16) {
            SelahCard {
                VStack(alignment: .leading, spacing: 12) {
                    SelahTag("Unlocked", tint: SelahPalette.mint)
                    Text("Apps unlocked")
                        .font(.selahHeading(22))
                    Text("Take the next \(profile.unlockDuration / 60) minutes with intention.")
                        .font(.selahBody(16))
                        .foregroundStyle(SelahPalette.ink.opacity(0.7))
                }
            }

            Button("Return") {
                onComplete()
            }
            .buttonStyle(SelahGhostButtonStyle())
        }
    }

    private func moodTint(_ mood: PrayerMood) -> Color {
        switch mood {
        case .grateful:
            return SelahPalette.lemon
        case .anxious:
            return SelahPalette.sky
        case .distracted:
            return SelahPalette.blush
        case .tired:
            return SelahPalette.mint
        case .seeking:
            return SelahPalette.lilac
        case .joyful:
            return SelahPalette.accent
        }
    }

    private func completePrayer(mood: PrayerMood, template: PrayerTemplate) {
        let event = PrayerEvent(
            timestamp: Date(),
            mood: mood.rawValue,
            templateId: template.id,
            tradition: profile.tradition,
            vibe: profile.vibe,
            unlockDuration: profile.unlockDuration
        )
        modelContext.insert(event)
        screenTimeManager.unlockApps(duration: TimeInterval(profile.unlockDuration))
    }
}
