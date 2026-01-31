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
        let title = ShieldConfiguration.Label(text: "Selah", color: .label)
        let subtitle = ShieldConfiguration.Label(text: "Pause to unlock", color: .secondaryLabel)
        let buttonLabel = ShieldConfiguration.Label(text: "Pray to Unlock", color: .white)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: .systemBackground,
            icon: UIImage(systemName: "hands.sparkles"),
            title: title,
            subtitle: subtitle,
            primaryButtonLabel: buttonLabel,
            primaryButtonBackgroundColor: .systemBlue,
            secondaryButtonLabel: nil
        )
    }
}
