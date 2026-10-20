import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }

    private func makeConfiguration() -> ShieldConfiguration {
        let paper = dynamic(light: 0xF8F2EA, dark: 0x16110E)
        let ink = dynamic(light: 0x1F140E, dark: 0xF3EAE0)
        let inkSoft = dynamic(light: 0x6B5A4E, dark: 0xB7A797)
        let clay = UIColor(red: 0.66, green: 0.31, blue: 0.18, alpha: 1)

        let icon = UIImage(systemName: "hands.and.sparkles")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 44, weight: .light))
            .withTintColor(clay, renderingMode: .alwaysOriginal)

        return ShieldConfiguration(
            backgroundBlurStyle: nil,
            backgroundColor: paper,
            icon: icon,
            title: ShieldConfiguration.Label(text: "Selah. Pause for a moment.", color: ink),
            subtitle: ShieldConfiguration.Label(
                text: "This app is resting. Open Selah Time to pray or read a short passage, then come back.",
                color: inkSoft
            ),
            primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
            primaryButtonBackgroundColor: clay,
            secondaryButtonLabel: nil
        )
    }

    private func dynamic(light: UInt32, dark: UInt32) -> UIColor {
        UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        }
    }
}
