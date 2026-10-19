import SwiftUI
import SwiftData

/// The pause that stands between the user and their apps: breathe, then pray or read, then go in peace.
struct PrayerFlowView: View {
    @EnvironmentObject private var screenTimeManager: ScreenTimeManager
    @EnvironmentObject private var templateStore: PrayerTemplateStore
    @EnvironmentObject private var readingStore: ReadingStore
    @Environment(\.modelContext) private var modelContext

    let profile: UserProfile
    var onComplete: () -> Void

    @State private var step: Step = .arrive
    @State private var hasBreathed = false
    @State private var selectedMood: PrayerMood?
    @State private var selectedTemplate: PrayerTemplate?
    @State private var selectedReading: Reading?
    @State private var reachedEndOfReading = false
    @State private var completedKind: PauseKind?

    enum Step {
        case arrive
        case mood
        case prayer
        case reading
        case done
    }

    var body: some View {
        ZStack {
            SelahBackground()

            VStack(spacing: 0) {
                topBar

                Group {
                    switch step {
                    case .arrive:
                        arriveStep
                    case .mood:
                        moodStep
                    case .prayer:
                        prayerStep
                    case .reading:
                        readingStep
                    case .done:
                        doneStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(y: 12)),
                    removal: .opacity
                ))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: step)
        .sensoryFeedback(.success, trigger: completedKind)
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack {
            if step == .mood || step == .prayer || step == .reading {
                Button {
                    goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(SelahTextButtonStyle())
                .accessibilityLabel("Back")
            }

            Spacer()

            if step != .done {
                Button("Not now") {
                    onComplete()
                }
                .buttonStyle(SelahTextButtonStyle())
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 12)
    }

    // MARK: Arrive

    private var arriveStep: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            BreathingCircle(size: 200)

            VStack(spacing: 12) {
                Text("Selah.")
                    .font(.selahDisplay(44))
                    .foregroundStyle(SelahPalette.ink)
                Text(hasBreathed ? "How would you like to spend this pause?" : "Breathe in slowly… and out.")
                    .font(.selahBody(17))
                    .foregroundStyle(SelahPalette.inkSoft)
                    .multilineTextAlignment(.center)
                    .contentTransition(.opacity)
            }
            .padding(.top, 8)

            Spacer(minLength: 24)

            VStack(spacing: 12) {
                pauseChoice(.prayer) {
                    step = .mood
                }
                if let reading = readingStore.nextReading {
                    pauseChoice(.reading, detail: "\(reading.title) · \(reading.reference)") {
                        selectedReading = reading
                        reachedEndOfReading = false
                        step = .reading
                    }
                }
            }
            .opacity(hasBreathed ? 1 : 0)
            .offset(y: hasBreathed ? 0 : 16)
            .allowsHitTesting(hasBreathed)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .task {
            guard !hasBreathed else { return }
            try? await Task.sleep(for: .seconds(4))
            withAnimation(.easeOut(duration: 0.6)) {
                hasBreathed = true
            }
        }
    }

    private func pauseChoice(_ kind: PauseKind, detail: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                SelahGlyph(systemName: kind.systemImage, tint: kind == .prayer ? SelahPalette.clay : SelahPalette.olive)
                VStack(alignment: .leading, spacing: 3) {
                    Text(kind.title)
                        .font(.selahHeading(17))
                    Text(detail ?? kind.subtitle)
                        .font(.selahBody(14))
                        .foregroundStyle(SelahPalette.inkSoft)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(SelahPalette.inkSoft)
            }
        }
        .buttonStyle(SelahChoiceButtonStyle())
    }

    // MARK: Pray

    private var moodStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    SelahEyebrow("Pray", tint: SelahPalette.clay)
                    Text("How are you, really?")
                        .font(.selahTitle(32))
                        .foregroundStyle(SelahPalette.ink)
                    Text("Be honest. God already knows.")
                        .font(.selahBody(16))
                        .foregroundStyle(SelahPalette.inkSoft)
                }

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(PrayerMood.allCases) { mood in
                        Button {
                            selectedMood = mood
                            selectedTemplate = templateStore.template(for: profile, mood: mood)
                            step = .prayer
                        } label: {
                            VStack(alignment: .leading, spacing: 18) {
                                Image(systemName: mood.systemImage)
                                    .font(.system(size: 22, weight: .regular))
                                    .foregroundStyle(SelahPalette.clay)
                                Text(mood.displayName)
                                    .font(.selahHeading(17))
                            }
                            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
                        }
                        .buttonStyle(SelahChoiceButtonStyle(isSelected: selectedMood == mood))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
    }

    private var prayerStep: some View {
        VStack(spacing: 0) {
            ScrollView {
                if let template = selectedTemplate, let mood = selectedMood {
                    VStack(alignment: .leading, spacing: 28) {
                        SelahEyebrow("For when you're \(mood.displayName.lowercased())", tint: SelahPalette.clay)

                        VStack(alignment: .leading, spacing: 14) {
                            Text("“\(template.verseText)”")
                                .font(.selahScripture(26))
                                .lineSpacing(6)
                                .foregroundStyle(SelahPalette.ink)
                            if let reference = template.verseReference {
                                Text("\(reference) · \(template.translation)")
                                    .font(.selahLabel(14))
                                    .foregroundStyle(SelahPalette.inkSoft)
                            }
                        }

                        Rectangle()
                            .fill(SelahPalette.clay)
                            .frame(width: 32, height: 2)

                        VStack(alignment: .leading, spacing: 12) {
                            SelahEyebrow("Pray")
                            Text(template.prayer)
                                .font(.selahScripture(20))
                                .lineSpacing(6)
                                .foregroundStyle(SelahPalette.ink)
                            Text("Pray it slowly. Add your own words if you'd like.")
                                .font(.selahBody(14))
                                .foregroundStyle(SelahPalette.inkSoft)
                                .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                } else {
                    Text("No prayer is available right now.")
                        .font(.selahBody(16))
                        .foregroundStyle(SelahPalette.inkSoft)
                        .padding(24)
                }
            }

            if let template = selectedTemplate, let mood = selectedMood {
                bottomActions {
                    Button("Amen") {
                        completePrayer(mood: mood, template: template)
                    }
                    .buttonStyle(SelahPrimaryButtonStyle())
                }
            }
        }
    }

    // MARK: Read

    private var readingStep: some View {
        VStack(spacing: 0) {
            ScrollView {
                if let reading = selectedReading {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 10) {
                            SelahEyebrow(readingPosition, tint: SelahPalette.olive)
                            Text(reading.title)
                                .font(.selahTitle(32))
                                .foregroundStyle(SelahPalette.ink)
                            Text("\(reading.reference) · \(reading.translation)")
                                .font(.selahLabel(14))
                                .foregroundStyle(SelahPalette.inkSoft)
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(reading.verses, id: \.number) { verse in
                                (Text("\(verse.number) ")
                                    .font(.selahLabel(12))
                                    .baselineOffset(6)
                                    .foregroundStyle(SelahPalette.olive)
                                 + Text(verse.text)
                                    .font(.selahScripture(21))
                                    .foregroundStyle(SelahPalette.ink))
                                    .lineSpacing(6)
                            }
                        }

                        SelahCard {
                            VStack(alignment: .leading, spacing: 8) {
                                SelahEyebrow("Reflect", tint: SelahPalette.olive)
                                Text(reading.reflection)
                                    .font(.selahBody(17))
                                    .foregroundStyle(SelahPalette.ink)
                            }
                        }

                        // Appears only once scrolled into view, since the stack is lazy.
                        Color.clear
                            .frame(height: 1)
                            .onAppear { reachedEndOfReading = true }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }

            if let reading = selectedReading {
                bottomActions {
                    Button(reachedEndOfReading ? "I've read it" : "Read to the end") {
                        completeReading(reading)
                    }
                    .buttonStyle(SelahPrimaryButtonStyle())
                    .disabled(!reachedEndOfReading)
                }
            }
        }
    }

    // MARK: Done

    private var doneStep: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                SelahGlyph(systemName: "sun.horizon", tint: SelahPalette.gold, size: 72)

                Text("Go in peace.")
                    .font(.selahDisplay(40))
                    .foregroundStyle(SelahPalette.ink)

                Text("Your apps are open for \(SelahFormat.minutes(profile.unlockDuration)). Use them with intention.")
                    .font(.selahBody(17))
                    .foregroundStyle(SelahPalette.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                if let carry = carryWord {
                    SelahCard {
                        VStack(alignment: .leading, spacing: 8) {
                            SelahEyebrow("Carry this with you")
                            Text(carry)
                                .font(.selahScripture(18))
                                .foregroundStyle(SelahPalette.ink)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            bottomActions {
                Button("Done") {
                    onComplete()
                }
                .buttonStyle(SelahPrimaryButtonStyle())
            }
        }
    }

    private var readingPosition: String {
        let count = readingStore.readings.count
        guard count > 0 else { return "Reading" }
        return "Reading \(readingStore.completedCount % count + 1) of \(count)"
    }

    private var carryWord: String? {
        switch completedKind {
        case .prayer:
            guard let template = selectedTemplate else { return nil }
            return [template.verseText, template.verseReference].compactMap { $0 }.joined(separator: " — ")
        case .reading:
            return selectedReading?.reflection
        case nil:
            return nil
        }
    }

    // MARK: Helpers

    private func bottomActions<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 8) {
            content()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(SelahPalette.paper.opacity(0.94))
        .overlay(alignment: .top) {
            Rectangle().fill(SelahPalette.hairline).frame(height: 1)
        }
    }

    private func goBack() {
        switch step {
        case .prayer:
            step = .mood
        case .mood, .reading:
            step = .arrive
        case .arrive, .done:
            break
        }
    }

    private func completePrayer(mood: PrayerMood, template: PrayerTemplate) {
        let event = PrayerEvent(
            timestamp: Date(),
            mood: mood.rawValue,
            templateId: template.id,
            tradition: profile.tradition,
            vibe: profile.vibe,
            unlockDuration: profile.unlockDuration,
            kind: .prayer
        )
        modelContext.insert(event)
        screenTimeManager.unlockApps(duration: TimeInterval(profile.unlockDuration))
        completedKind = .prayer
        step = .done
    }

    private func completeReading(_ reading: Reading) {
        let event = PrayerEvent(
            timestamp: Date(),
            mood: "",
            templateId: reading.id,
            tradition: profile.tradition,
            vibe: profile.vibe,
            unlockDuration: profile.unlockDuration,
            kind: .reading
        )
        modelContext.insert(event)
        readingStore.markCompleted(reading)
        screenTimeManager.unlockApps(duration: TimeInterval(profile.unlockDuration))
        completedKind = .reading
        step = .done
    }
}
