import Foundation
import GovKit
import GovKitUI
import SwiftUI

final class WelcomeOnboardingViewModel: InfoViewModelInterface,
                                        ProgressIndicating {
    let completeAction: () -> Void
    let openURLAction: (URL) -> Void
    let termsURL: URL

    @Published var showProgressView: Bool = false

    init(completeAction: @escaping () -> Void,
         openURLAction: @escaping (URL) -> Void,
         termsURL: URL) {
        self.completeAction = completeAction
        self.openURLAction = openURLAction
        self.termsURL = termsURL
    }

    var analyticsService: AnalyticsServiceInterface? { nil }
    var trackingName: String { "" }
    var trackingTitle: String { "" }

    var title: String {
        String.onboarding.localized("welcomeTitle")
    }

    var markdownText: String {
        String(
            localized: .Onboarding.welcomeSubtitleText(
                termsURL.absoluteString,
                Constants.API.privacyPolicyUrl.absoluteString
            )
        )
    }

    var primaryButtonTitle: String {
        String.signOut.localized("signInRetryButtonTitle")
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        let localTitle = String(localized: .Onboarding.welcomeButtonTitle)
        return .init(
            localisedTitle: localTitle,
            action: { [weak self] in
                self?.showProgressView = true
                self?.completeAction()
            }
        )
    }

    var visualAssetContent: VisualAssetContent {
        .decorativeImage("onboarding_welcome")
    }

    var subtitleFont: Font {
        Font.govUK.title1
    }

    var bottomContentText: String? {
        guard let versionNumber = Bundle.main.versionNumber
        else { return "" }
        return "\(String.onboarding.localized("appVersionText")) \(versionNumber)"
    }

    var animationDelay: TimeInterval {
        showProgressView ? 1.0 : 0.0
    }

    var accessibilityLabel: String {
        String.onboarding.localized("loadingIndicatorAccessibilityTitle")
    }
}
