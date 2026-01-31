import SwiftUI
import SwiftData
import FamilyControls

struct OnboardingFlowView: View {
    @EnvironmentObject private var screenTimeManager: ScreenTimeManager
    @Environment(\.modelContext) private var modelContext

    @State private var step: Step = .welcome
    @State private var selectedTradition: Tradition = .evangelical
    @State private var selectedVibe: Vibe = .pastoral
    @State private var bibleTranslation: String = "ESV"
    @State private var unlockDurationMinutes: Double = 10
    @State private var showTranslationPicker = false

    enum Step: Int, CaseIterable {
        case welcome
        case authorization
        case selection
        case profile
        case duration
        case ready
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SelahBackground()

                VStack(spacing: 18) {
                    ProgressView(value: Double(step.rawValue + 1), total: Double(Step.allCases.count))
                        .tint(SelahPalette.accent)
                        .padding(.top, 12)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            switch step {
                            case .welcome:
                                welcomeView
                            case .authorization:
                                authorizationView
                            case .selection:
                                selectionView
                            case .profile:
                                profileView
                            case .duration:
                                durationView
                            case .ready:
                                readyView
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack {
                        if step != .welcome {
                            Button("Back") {
                                withAnimation { step = Step(rawValue: step.rawValue - 1) ?? step }
                            }
                            .buttonStyle(SelahGhostButtonStyle())
                        }

                        Spacer()

                        Button(step == .ready ? "Finish" : "Continue") {
                            handleContinue()
                        }
                        .buttonStyle(SelahPrimaryButtonStyle())
                        .disabled(step == .authorization && screenTimeManager.authorizationStatus != .approved)
                    }
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Welcome to Selah Time")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var welcomeView: some View {
        SelahCard {
            VStack(alignment: .leading, spacing: 12) {
                SelahTag("Start here", tint: SelahPalette.lemon)
                Text("Selah turns distraction into devotion.")
                    .font(.selahHeading(24))
                Text("Select the apps you want to pause, and Selah will invite you to pray before each unlock.")
                    .font(.selahBody(16))
                    .foregroundStyle(SelahPalette.ink.opacity(0.7))
            }
        }
    }

    private var authorizationView: some View {
        SelahCard {
            VStack(alignment: .leading, spacing: 12) {
                SelahTag("Permissions", tint: SelahPalette.mint)
                Text("Screen Time Authorization")
                    .font(.selahHeading(22))
                Text("Selah needs Screen Time permission to show shields and pause your apps.")
                    .font(.selahBody(16))
                    .foregroundStyle(SelahPalette.ink.opacity(0.7))

                Text(statusText)
                    .font(.selahLabel(14))
                    .foregroundStyle(screenTimeManager.authorizationStatus == .approved ? SelahPalette.mint : SelahPalette.ink.opacity(0.6))

                Button("Request Permission") {
                    Task {
                        _ = await screenTimeManager.requestAuthorization()
                    }
                }
                .buttonStyle(SelahGhostButtonStyle())
            }
        }
    }

    private var selectionView: some View {
        SelahCard {
            VStack(alignment: .leading, spacing: 12) {
                SelahTag("Choices", tint: SelahPalette.blush)
                Text("Choose Apps to Pause")
                    .font(.selahHeading(22))
                Text("Pick the apps or categories that will require a prayer before opening.")
                    .font(.selahBody(16))
                    .foregroundStyle(SelahPalette.ink.opacity(0.7))

                FamilyActivityPicker(selection: $screenTimeManager.selection)
                    .frame(minHeight: 320)
            }
        }
    }

    private var profileView: some View {
        SelahCard {
            VStack(alignment: .leading, spacing: 16) {
                SelahTag("Personalize", tint: SelahPalette.lilac)
                Text("Personalize Your Prayers")
                    .font(.selahHeading(22))

                Picker("Tradition", selection: $selectedTradition) {
                    ForEach(Tradition.allCases) { tradition in
                        Text(tradition.displayName).tag(tradition)
                    }
                }
                .pickerStyle(.menu)

                Picker("Vibe", selection: $selectedVibe) {
                    ForEach(Vibe.allCases) { vibe in
                        Text(vibe.displayName).tag(vibe)
                    }
                }
                .pickerStyle(.menu)

                VStack(alignment: .leading) {
                    Toggle("Set a Bible translation", isOn: $showTranslationPicker)
                    if showTranslationPicker {
                        TextField("Translation (e.g. ESV)", text: $bibleTranslation)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    private var durationView: some View {
        SelahCard {
            VStack(alignment: .leading, spacing: 16) {
                SelahTag("Timing", tint: SelahPalette.sky)
                Text("Unlock Duration")
                    .font(.selahHeading(22))
                Text("How long should apps stay unlocked after a prayer?")
                    .font(.selahBody(16))
                    .foregroundStyle(SelahPalette.ink.opacity(0.7))

                HStack {
                    Text("\(Int(unlockDurationMinutes)) min")
                        .font(.selahHeading(20))
                    Spacer()
                }

                Slider(value: $unlockDurationMinutes, in: 5...30, step: 5)
                    .tint(SelahPalette.accent)
                Text("Default: 10 minutes")
                    .font(.selahLabel(12))
                    .foregroundStyle(SelahPalette.ink.opacity(0.6))
            }
        }
    }

    private var readyView: some View {
        SelahCard {
            VStack(alignment: .leading, spacing: 12) {
                SelahTag("All set", tint: SelahPalette.mint)
                Text("You're Ready")
                    .font(.selahHeading(22))
                Text("Selah will now shield the selected apps. Each unlock will begin with a short prayer.")
                    .font(.selahBody(16))
                    .foregroundStyle(SelahPalette.ink.opacity(0.7))
            }
        }
    }

    private var statusText: String {
        switch screenTimeManager.authorizationStatus {
        case .approved:
            return "Permission granted."
        case .denied:
            return "Permission denied. Selah cannot continue without Screen Time access."
        case .notDetermined:
            return "Permission not yet requested."
        @unknown default:
            return "Unknown status."
        }
    }

    private func handleContinue() {
        if step == .authorization && screenTimeManager.authorizationStatus != .approved {
            return
        }

        if step == .ready {
            let profile = UserProfile(
                tradition: selectedTradition.rawValue,
                vibe: selectedVibe.rawValue,
                bibleTranslation: showTranslationPicker ? bibleTranslation : nil,
                unlockDuration: Int(unlockDurationMinutes * 60)
            )
            modelContext.insert(profile)
            screenTimeManager.applyShielding()
            return
        }

        if let next = Step(rawValue: step.rawValue + 1) {
            withAnimation { step = next }
        }
    }
}
