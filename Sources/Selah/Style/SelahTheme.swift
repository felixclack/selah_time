import SwiftUI

enum SelahPalette {
    static let ink = Color(red: 0.13, green: 0.12, blue: 0.18)
    static let accent = Color(red: 0.97, green: 0.40, blue: 0.46)
    static let accentDeep = Color(red: 0.90, green: 0.24, blue: 0.38)
    static let mint = Color(red: 0.38, green: 0.83, blue: 0.73)
    static let sky = Color(red: 0.48, green: 0.69, blue: 0.98)
    static let lemon = Color(red: 0.99, green: 0.88, blue: 0.50)
    static let blush = Color(red: 0.99, green: 0.78, blue: 0.84)
    static let lilac = Color(red: 0.78, green: 0.70, blue: 0.98)
}

struct SelahBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    SelahPalette.sky.opacity(0.55),
                    SelahPalette.blush.opacity(0.45),
                    SelahPalette.lemon.opacity(0.40)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(SelahPalette.mint.opacity(0.35))
                .frame(width: 220, height: 220)
                .offset(x: -120, y: -180)
                .blur(radius: 2)

            RoundedRectangle(cornerRadius: 48, style: .continuous)
                .fill(SelahPalette.lilac.opacity(0.35))
                .frame(width: 320, height: 220)
                .rotationEffect(.degrees(16))
                .offset(x: 140, y: -120)
                .blur(radius: 4)

            Circle()
                .fill(SelahPalette.accent.opacity(0.20))
                .frame(width: 260, height: 260)
                .offset(x: 140, y: 260)
                .blur(radius: 6)
        }
    }
}

struct SelahCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.35),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: colorScheme == .dark ? Color.black.opacity(0.35) : Color.black.opacity(0.12),
                radius: 18,
                x: 0,
                y: 10
            )
    }
}

struct SelahTag: View {
    let text: String
    let tint: Color

    init(_ text: String, tint: Color = SelahPalette.accent) {
        self.text = text
        self.tint = tint
    }

    var body: some View {
        Text(text.uppercased())
            .font(.selahLabel(12))
            .foregroundStyle(SelahPalette.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(tint.opacity(0.25), in: Capsule())
    }
}

struct SelahRowBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.ultraThinMaterial)
    }
}

struct SelahPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.selahButton(17))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [SelahPalette.accent, SelahPalette.accentDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
            .shadow(color: SelahPalette.accent.opacity(0.35), radius: 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}

struct SelahGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.selahButton(16))
            .foregroundStyle(SelahPalette.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(SelahPalette.ink.opacity(0.12), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}

struct SelahSoftButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.selahBody(16))
            .foregroundStyle(SelahPalette.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint.opacity(configuration.isPressed ? 0.35 : 0.22), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(tint.opacity(0.35), lineWidth: 1)
            )
    }
}

extension Font {
    static func selahTitle(_ size: CGFloat) -> Font {
        .custom("AvenirNextRounded-Bold", size: size)
    }

    static func selahHeading(_ size: CGFloat) -> Font {
        .custom("AvenirNextRounded-DemiBold", size: size)
    }

    static func selahBody(_ size: CGFloat) -> Font {
        .custom("AvenirNextRounded-Regular", size: size)
    }

    static func selahLabel(_ size: CGFloat) -> Font {
        .custom("AvenirNextRounded-Medium", size: size)
    }

    static func selahButton(_ size: CGFloat) -> Font {
        .custom("AvenirNextRounded-DemiBold", size: size)
    }
}
