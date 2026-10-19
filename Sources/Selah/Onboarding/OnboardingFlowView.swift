import SwiftUI
import SwiftData
import FamilyControls

struct OnboardingFlowView: View {
    @EnvironmentObject private var screenTimeManager: ScreenTimeManager
    @Environment(\.modelContext) private var modelContext

    @State private var step: Step = .welcome
    @State private var selectedTradition: Tradition = .evangelical
    @State private var selectedVibe: Vibe = .pastoral
    @State private var bibleTranslation: String?
    @State private var unlockDurationMinutes: Int = 10
    @State private var showAppPicker = false
    @State private var isRequestingAuthorization = false

    enum Step: Int, CaseIterable {
        case welcome
        case howItWorks
        case authorization
        case selection
        case profile
        case duration
        case ready
    }

    var body: some View {
        ZStack {
            SelahBackground()

            VStack(spacing: 0) {
                topBar

                ScrollView {
                    Group {
                        switch step {
                        case .welcome:
                            welcomeView
                        case .howItWorks:
                            howItWorksView
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
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    .id(step)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 12)),
                        removal: .opacity
                    ))
                }
                .scrollBounceBehavior(.basedOnSize)

                bottomBar
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
        .familyActivityPicker(isPresented: $showAppPicker, selection: $screenTimeManager.selection)
    }

    // MARK: Chrome

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                if let previous = Step(rawValue: step.rawValue - 1) {
                    step = previous
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(SelahTextButtonStyle())
            .opacity(step == .welcome ? 0 : 1)
            .disabled(step == .welcome)
            .accessibilityLabel("Back")

            HStack(spacing: 6) {
                ForEach(Step.allCases, id: \.rawValue) { item in
                    Capsule()
                        .fill(item.rawValue <= step.rawValue ? SelahPalette.clay : SelahPalette.hairline)
                        .frame(height: 4)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Step \(step.rawValue + 1) of \(Step.allCases.count)")

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 8)
    }

    private var bottomBar: some View {
        VStack(spacing: 4) {
            Button(primaryTitle) {
                handlePrimary()
            }
            .buttonStyle(SelahPrimaryButtonStyle())
            .disabled(isRequestingAuthorization)

            if step == .selection && !hasSelection {
                Button("I'll choose later") {
                    advance()
                }
                .buttonStyle(SelahTextButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    private var primaryTitle: String {
        switch step {
        case .welcome:
            return "Get started"
        case .authorization:
            switch screenTimeManager.authorizationStatus {
            case .approved: return "Continue"
            case .denied: return "Try again"
            default: return "Allow Screen Time access"
            }
        case .selection:
            return hasSelection ? "Continue" : "Choose apps"
        case .ready:
            return "Begin"
        default:
            return "Continue"
        }
    }

    // MARK: Steps

    private var welcomeView: some View {
        VStack(alignment: .leading, spacing: 24) {
            BreathingCircle(size: 220)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)

            VStack(alignment: .leading, spacing: 14) {
                SelahEyebrow("Selah Time", tint: SelahPalette.clay)
                Text("Turn the reach for your phone into a reach for God.")
                    .font(.selahDisplay(36))
                    .foregroundStyle(SelahPalette.ink)
                Text("Selah Time gently pauses the apps you choose. Before they open, take a moment to pray or read a short passage of Scripture.")
                    .font(.selahBody(17))
                    .foregroundStyle(SelahPalette.inkSoft)
            }
        }
    }

    private var howItWorksView: some View {
        VStack(alignment: .leading, spacing: 28) {
            heading(eyebrow: "How it works", title: "A small pause, many times a day.")

            VStack(alignment: .leading, spacing: 22) {
                explainer(number: 1, title: "Reach for an app",
                          body: "The apps you choose rest behind a quiet Selah screen.")
                explainer(number: 2, title: "Pause with God",
                          body: "Open Selah Time, take a breath, then pray or read a passage.")
                explainer(number: 3, title: "Go in peace",
                          body: "Your apps open for a few minutes, then rest again on their own.")
            }
        }
    }

    private var authorizationView: some View {
        VStack(alignment: .leading, spacing: 24) {
            SelahGlyph(systemName: "hourglass", tint: SelahPalette.olive, size: 64)

            heading(
                eyebrow: "Permission",
                title: "Allow Screen Time access",
                body: "Selah Time uses Apple's Screen Time to rest your apps. Your choices stay on this device, and Selah Time never sees what you do inside other apps."
            )

            HStack(spacing: 10) {
                Image(systemName: authorizationIcon)
                Text(authorizationStatusText)
                    .font(.selahLabel(15))
            }
            .foregroundStyle(screenTimeManager.authorizationStatus == .approved ? SelahPalette.olive : SelahPalette.inkSoft)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(SelahPalette.surface, in: Capsule())
            .overlay(Capsule().stroke(SelahPalette.hairline, lineWidth: 1))
        }
    }

    private var selectionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            heading(
                eyebrow: "Your apps",
                title: "Which apps pull you in?",
                body: "Choose the apps or categories that should wait for a pause. Social media is a good place to start."
            )

            Button {
                showAppPicker = true
            } label: {
                HStack(spacing: 14) {
                    SelahGlyph(systemName: hasSelection ? "checkmark" : "square.grid.2x2", tint: hasSelection ? SelahPalette.olive : SelahPalette.clay)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(hasSelection ? "Apps chosen" : "Choose apps")
                            .font(.selahHeading(17))
                        Text(screenTimeManager.selection.summary)
                            .font(.selahBody(14))
                            .foregroundStyle(SelahPalette.inkSoft)
                    }
                    Spacer()
                    Text(hasSelection ? "Edit" : "")
                        .font(.selahLabel(15))
                        .foregroundStyle(SelahPalette.clay)
                }
            }
            .buttonStyle(SelahChoiceButtonStyle(isSelected: hasSelection))
        }
    }

    private var profileView: some View {
        VStack(alignment: .leading, spacing: 28) {
            heading(
                eyebrow: "Personalize",
                title: "How do you like to pray?",
                body: "Prayers are written in different voices. Pick what feels like home."
            )

            VStack(alignment: .leading, spacing: 12) {
                SelahEyebrow("Tradition")
                FlowLayout(spacing: 8) {
                    ForEach(Tradition.allCases) { tradition in
                        SelahPill(title: tradition.displayName, isSelected: selectedTradition == tradition) {
                            selectedTradition = tradition
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SelahEyebrow("Voice")
                ForEach(Vibe.allCases) { vibe in
                    Button {
                        selectedVibe = vibe
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(vibe.displayName)
                                .font(.selahHeading(16))
                            Text(vibe.detail)
                                .font(.selahBody(14))
                                .foregroundStyle(SelahPalette.inkSoft)
                        }
                    }
                    .buttonStyle(SelahChoiceButtonStyle(isSelected: selectedVibe == vibe))
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SelahEyebrow("Bible translation · optional")
                FlowLayout(spacing: 8) {
                    SelahPill(title: "No preference", isSelected: bibleTranslation == nil) {
                        bibleTranslation = nil
                    }
                    ForEach(BibleTranslation.options, id: \.self) { translation in
                        SelahPill(title: translation, isSelected: bibleTranslation == translation) {
                            bibleTranslation = translation
                        }
                    }
                }
            }
        }
    }

    private var durationView: some View {
        VStack(alignment: .leading, spacing: 32) {
            heading(
                eyebrow: "Unlock window",
                title: "How long should apps stay open?",
                body: "After each pause, your apps open for this long, then rest again."
            )

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(unlockDurationMinutes)")
                    .font(.selahDisplay(72))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text("minutes")
                    .font(.selahBody(20))
                    .foregroundStyle(SelahPalette.inkSoft)
            }
            .foregroundStyle(SelahPalette.ink)
            .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                ForEach(SettingsView.durationOptions, id: \.self) { minutes in
                    SelahPill(title: "\(minutes) min", isSelected: unlockDurationMinutes == minutes) {
                        withAnimation { unlockDurationMinutes = minutes }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Text("Shorter windows mean more moments to pause. You can change this anytime.")
                .font(.selahBody(14))
                .foregroundStyle(SelahPalette.inkSoft)
        }
    }

    private var readyView: some View {
        VStack(alignment: .leading, spacing: 24) {
            BreathingCircle(size: 200)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)

            heading(
                eyebrow: "All set",
                title: "You're ready.",
                body: "Next time you reach for a paused app, you'll see a Selah screen. Open Selah Time, pause with God, then go in peace."
            )
        }
    }

    // MARK: Building blocks

    private func heading(eyebrow: String, title: String, body: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SelahEyebrow(eyebrow, tint: SelahPalette.clay)
            Text(title)
                .font(.selahTitle(32))
                .foregroundStyle(SelahPalette.ink)
            if let body {
                Text(body)
                    .font(.selahBody(17))
                    .foregroundStyle(SelahPalette.inkSoft)
            }
        }
    }

    private func explainer(number: Int, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)")
                .font(.selahTitle(18))
                .foregroundStyle(SelahPalette.clay)
                .frame(width: 40, height: 40)
                .background(SelahPalette.clay.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.selahHeading(17))
                    .foregroundStyle(SelahPalette.ink)
                Text(body)
                    .font(.selahBody(16))
                    .foregroundStyle(SelahPalette.inkSoft)
            }
        }
    }

    private var hasSelection: Bool {
        !screenTimeManager.selection.applicationTokens.isEmpty
            || !screenTimeManager.selection.categoryTokens.isEmpty
    }

    private var authorizationIcon: String {
        switch screenTimeManager.authorizationStatus {
        case .approved: return "checkmark.circle.fill"
        case .denied: return "exclamationmark.circle"
        default: return "circle.dashed"
        }
    }

    private var authorizationStatusText: String {
        switch screenTimeManager.authorizationStatus {
        case .approved:
            return "Access granted"
        case .denied:
            return "Access declined. Selah Time can't pause apps without it."
        case .notDetermined:
            return "Not yet allowed"
        @unknown default:
            return "Unknown status"
        }
    }

    // MARK: Actions

    private func handlePrimary() {
        switch step {
        case .authorization where screenTimeManager.authorizationStatus != .approved:
            isRequestingAuthorization = true
            Task { @MainActor in
                let approved = await screenTimeManager.requestAuthorization()
                isRequestingAuthorization = false
                if approved {
                    advance()
                }
            }
        case .selection where !hasSelection:
            showAppPicker = true
        case .ready:
            finish()
        default:
            advance()
        }
    }

    private func advance() {
        if let next = Step(rawValue: step.rawValue + 1) {
            step = next
        }
    }

    private func finish() {
        let profile = UserProfile(
            tradition: selectedTradition.rawValue,
            vibe: selectedVibe.rawValue,
            bibleTranslation: bibleTranslation,
            unlockDuration: unlockDurationMinutes * 60
        )
        modelContext.insert(profile)
        screenTimeManager.applyShielding()
    }
}
