import Foundation
import GovKit
import GovKitUI
import SwiftUI

final class ServiceAccountConsentViewModel: InfoViewModelInterface {
    private let completionAction: () -> Void
    private let cancelAction: () -> Void
    var analyticsService: AnalyticsServiceInterface?

    init(analyticsService: AnalyticsServiceInterface,
         completionAction: @escaping () -> Void,
         cancelAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.completionAction = completionAction
        self.cancelAction = cancelAction
    }

    var title: String {
        String.serviceAccount.localized("dvlaConsentInfoTitle")
    }

    var subtitle: String {
        String.serviceAccount.localized("dvlaConsentInfoSubtitle")
    }

    var primaryButtonTitle: String {
        String.common.localized("continue")
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        GOVUKButton.ButtonViewModel(
            localisedTitle: primaryButtonTitle,
            action: { [weak self] in
                self?.completionAction()
            }
        )
    }

    var showPrimaryButton: Bool {
        true
    }

    var rightBarButtonItem: UIBarButtonItem {
        .cancel(
            target: self,
            action: #selector(cancel),
            tintColour: .govUK.text.linkSecondary
        )
    }

    var navBarHidden: Bool {
        false
    }

    var visualAssetContent: VisualAssetContent {
        .decorativeImage("driving")
    }

    var trackingTitle: String {
        title
    }

    var trackingName: String {
        ""
    }

    @objc
    func cancel() {
        cancelAction()
    }
}
