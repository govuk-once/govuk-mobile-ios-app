import Foundation
import GovKit
import GovKitUI

extension ErrorViewModel {
    static func chatError(
        _ chatError: ChatError,
        analyticsService: AnalyticsServiceInterface,
        action: @escaping () -> Void
    ) -> ErrorViewModel {
        let title: String
        let subtitle: String
        let buttonTitle: String

        switch chatError {
        case .networkUnavailable:
            title = String.common.localized("networkUnavailableErrorTitle")
            subtitle = String.common.localized("networkUnavailableErrorBody")
            buttonTitle = String.common.localized("networkUnavailableButtonTitle")
        case .pageNotFound:
            title = String.common.localized("genericErrorTitle")
            subtitle = String.chat.localized("pageNotFoundErrorBody")
            buttonTitle = String.chat.localized("pageNotFoundButtonTitle")
        default:
            title = String.common.localized("genericErrorTitle")
            subtitle = String.chat.localized("genericErrorBody")
            buttonTitle = ""
        }

        return ErrorViewModel(
            analyticsService: analyticsService,
            title: title,
            subtitle: subtitle,
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: buttonTitle,
            primaryAction: action,
            trackingName: "Chat Error"
        )
    }
}
