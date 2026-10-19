import SwiftUI
import UIKit

// MARK: - Palette

/// Warm paper-and-ink palette shared with the marketing site. Every color adapts to dark mode.
enum SelahPalette {
    static let paper = Color(light: 0xF8F2EA, dark: 0x16110E)
    static let paperDeep = Color(light: 0xEFE3D5, dark: 0x221A15)
    static let surface = Color(light: 0xFFFBF6, dark: 0x1D1612)
    static let ink = Color(light: 0x1F140E, dark: 0xF3EAE0)
    static let inkSoft = Color(light: 0x6B5A4E, dark: 0xB7A797)
    static let hairline = Color(light: 0x1F140E, dark: 0xF3EAE0, opacity: 0.10)
    static let clay = Color(light: 0xC0623F, dark: 0xE38D6C)
    static let olive = Color(light: 0x2F564F, dark: 0x86B6AA)
    static let gold = Color(light: 0xD9A24E, dark: 0xE6B66A)
    static let onAccent = Color(light: 0xFFFBF6, dark: 0x16110E)

    /// Primary accent used for calls to action.
    static let accent = clay
}

extension Color {
    init(light: UInt32, dark: UInt32, opacity: Double = 1) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light, alpha: opacity)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: Double = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: CGFloat(alpha)
        )
    }
}

// MARK: - Typography

/// Serif (New York) carries scripture and headlines; the system sans carries UI.
extension Font {
    static func selahDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    static func selahTitle(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }

    static func selahScripture(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    static func selahHeading(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold)
    }

    static func selahBody(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular)
    }

    static func selahLabel(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium)
    }

    static func selahButton(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold)
    }
}

// MARK: - Surfaces

struct SelahBackground: View {
    var body: some View {
        ZStack {
            SelahPalette.paper
            RadialGradient(
                colors: [SelahPalette.gold.opacity(0.18), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }
}

struct SelahCard<Content: View>: View {
    var padding: CGFloat = 20
    let content: Content

    init(padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SelahPalette.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(SelahPalette.hairline, lineWidth: 1)
            )
    }
}

struct SelahRowBackground: View {
    var body: some View {
        SelahPalette.surface
    }
}

/// Small tracked uppercase label that sits above headings.
struct SelahEyebrow: View {
    let text: String
    var tint: Color = SelahPalette.inkSoft

    init(_ text: String, tint: Color = SelahPalette.inkSoft) {
        self.text = text
        self.tint = tint
    }

    var body: some View {
        Text(text.uppercased())
            .font(.selahLabel(12))
            .tracking(1.6)
            .foregroundStyle(tint)
    }
}

/// An SF Symbol set in a soft tinted circle.
struct SelahGlyph: View {
    let systemName: String
    var tint: Color = SelahPalette.clay
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.42, weight: .medium))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.12), in: Circle())
    }
}

// MARK: - Buttons

struct SelahPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.selahButton(17))
            .foregroundStyle(SelahPalette.onAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(SelahPalette.ink.opacity(isEnabled ? 1 : 0.25), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SelahSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.selahButton(16))
            .foregroundStyle(SelahPalette.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(SelahPalette.ink.opacity(configuration.isPressed ? 0.10 : 0.06), in: Capsule())
    }
}

struct SelahTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.selahLabel(15))
            .foregroundStyle(SelahPalette.inkSoft)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// A selectable row or tile. Shows a filled state when `isSelected`.
struct SelahChoiceButtonStyle: ButtonStyle {
    var isSelected: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.selahBody(16))
            .foregroundStyle(SelahPalette.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? SelahPalette.clay.opacity(0.12) : SelahPalette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? SelahPalette.clay : SelahPalette.hairline, lineWidth: isSelected ? 1.5 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Compact pill used for short option sets such as durations and translations.
struct SelahPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.selahLabel(15))
                .foregroundStyle(isSelected ? SelahPalette.onAccent : SelahPalette.ink)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(minWidth: 56)
                .background(isSelected ? SelahPalette.ink : SelahPalette.surface, in: Capsule())
                .overlay(Capsule().stroke(isSelected ? .clear : SelahPalette.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Breathing

/// Slow expanding/contracting rings used to mark the start of a pause.
struct BreathingCircle: View {
    var size: CGFloat = 180
    @State private var expanded = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .fill(SelahPalette.gold.opacity(0.16))
                .scaleEffect(expanded ? 1 : 0.62)
            Circle()
                .fill(SelahPalette.clay.opacity(0.14))
                .scaleEffect(expanded ? 0.74 : 0.48)
            Circle()
                .fill(SelahPalette.clay.opacity(0.85))
                .frame(width: size * 0.16, height: size * 0.16)
        }
        .frame(width: size, height: size)
        .onAppear {
            guard !reduceMotion else {
                expanded = true
                return
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                expanded = true
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Formatting

enum SelahFormat {
    static func countdown(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded(.up)))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    static func minutes(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return minutes == 1 ? "1 minute" : "\(minutes) minutes"
    }
}

// MARK: - Layout

/// Wraps children onto new lines when they run out of horizontal space.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(subviews: subviews, width: proposal.width ?? .infinity)
        let height = rows.last.map { $0.y + $0.height } ?? 0
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrange(subviews: subviews, width: bounds.width)
        for row in rows {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: bounds.minY + row.y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
        }
    }

    private struct Row {
        var indices: [Int] = []
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func arrange(subviews: Subviews, width: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let proposedWidth = current.indices.isEmpty ? size.width : current.width + spacing + size.width
            if proposedWidth > width, !current.indices.isEmpty {
                rows.append(current)
                current = Row(y: current.y + current.height + spacing)
            }
            current.width = current.indices.isEmpty ? size.width : current.width + spacing + size.width
            current.height = max(current.height, size.height)
            current.indices.append(index)
        }
        if !current.indices.isEmpty {
            rows.append(current)
        }
        return rows
    }
}
