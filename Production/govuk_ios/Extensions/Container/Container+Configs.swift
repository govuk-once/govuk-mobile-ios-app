import Foundation

import FactoryKit
import Lottie
import SecureStore
import Qualtrics

extension Container {
    var lottieConfiguration: Factory<LottieConfiguration> {
        Factory(self) {
            LottieConfiguration.shared
        }
    }

    var accessibilityManager: Factory<AccessibilityManagerInterface> {
        Factory(self) {
            AccessibilityManager()
        }
    }

    var authenticatedSecureStoreConfiguration: Factory<SecureStorageConfiguration> {
        Factory(self) {
            let localAuthStrings = LocalAuthenticationLocalizedStrings(
                localizedReason: String.localAuthentication.localized(
                    "localizedReason"
                ),
                localisedFallbackTitle: "",
                localisedCancelTitle: String.common.localized(
                    "cancel"
                )
            )
            #if targetEnvironment(simulator)
            let accessControlLevel =
            SecureStorageConfiguration.AccessControlLevel.open
            #else
            let accessControlLevel =
            SecureStorageConfiguration.AccessControlLevel.currentBiometricsOnly
            #endif
            let config = SecureStorageConfiguration(
                id: "protectedSecureStorage",
                accessControlLevel: accessControlLevel,
                localAuthStrings: localAuthStrings
            )
            return config
        }
    }

    var openSecureStoreConfiguration: Factory<SecureStorageConfiguration> {
        Factory(self) {
            SecureStorageConfiguration(
                id: "openSecureStorage",
                accessControlLevel: SecureStorageConfiguration.AccessControlLevel.open
            )
        }
    }

    var qualtricsTheme: Factory<QualtricsTheme> {
        Factory(self) {
            return QualtricsTheme(
                mobileAppPromptTheme: .govUK,
                embeddedAppFeedbackTheme: .govUK
            )
        }
    }
}
