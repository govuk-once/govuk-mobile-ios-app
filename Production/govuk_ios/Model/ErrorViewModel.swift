import Foundation
import GovKit
import GovKitUI
import SwiftUI

final class ErrorViewModel: InfoViewModelInterface {
    let analyticsService: AnalyticsServiceInterface?
    let title: String
    let subtitle: String
    let visualAssetContent: VisualAssetContent

    let primaryButtonTitle: String
    let secondaryButtonTitle: String

    private let primaryAction: () -> Void
    private let secondaryAction: (() -> Void)?

    let trackingName: String

    init(
        analyticsService: AnalyticsServiceInterface,
        title: String,
        subtitle: String,
        visualAssetContent: VisualAssetContent,
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void,
        secondaryButtonTitle: String = "",
        secondaryAction: (() -> Void)? = nil,
        trackingName: String
    ) {
        self.analyticsService = analyticsService
        self.title = title
        self.subtitle = subtitle
        self.visualAssetContent = visualAssetContent
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryAction = primaryAction
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryAction = secondaryAction
        self.trackingName = trackingName
    }

    var trackingTitle: String {
        title
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        GOVUKButton.ButtonViewModel(
            localisedTitle: primaryButtonTitle,
            action: { [weak self] in
                self?.primaryAction()
            }
        )
    }

    var secondaryButtonViewModel: GOVUKButton.ButtonViewModel? {
        guard let action = secondaryAction else {
            return nil
        }
        return GOVUKButton.ButtonViewModel(
            localisedTitle: secondaryButtonTitle,
            action: action
        )
    }

    var showPrimaryButton: Bool {
        primaryButtonTitle != ""
    }
}
