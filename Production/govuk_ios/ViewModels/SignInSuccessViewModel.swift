import Foundation
import GovKit
import GovKitUI
import SwiftUI

final class SignInSuccessViewModel: InfoViewModelInterface {
    private let completion: () -> Void

    init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    var analyticsService: AnalyticsServiceInterface? { nil }
    var trackingName: String { "" }
    var trackingTitle: String { "" }

    var title: String {
        String.onboarding.localized("successfulSignInTitle")
    }

    var primaryButtonTitle: String {
        String.common.localized("continue")
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        let localTitle = primaryButtonTitle
        return .init(
            localisedTitle: localTitle,
            action: { [weak self] in
                self?.completion()
            }
        )
    }

    var visualAssetContent: VisualAssetContent {
        .decorativeImage("sign_in_success")
    }


    var subtitleFont: Font {
        Font.govUK.title1
    }
}
