import Foundation
import GovKitUI
import UIKit
import GovKit

class AppUnavailableContainerViewModel: ObservableObject {
    private let urlOpener: URLOpener
    let error: AppUnavailableError?
    private let dismissAction: () -> Void
    private let retryAction: (@escaping (Bool) -> Void) -> Void
    @Published var showProgressView: Bool = false

    private(set) var title = String.appAvailability.localized("unavailableTitle")
    private(set) var subheading = String.appAvailability.localized("unavailableSubheading")
    private(set) var buttonTitle = String.appAvailability.localized("goToGovUkButtonTitle")
    private(set) var buttonAccessibilityTitle =
    String.appAvailability.localized("goToGovUkAccessibilityButtonTitle")
    private(set) var buttonAccessibilityHint = String.common.localized("openWebLinkHint")

    var buttonViewModel: GOVUKButton.ButtonViewModel {
        .init(
            localisedTitle: buttonTitle,
            action: { [weak self] in
                if self?.error == .networkUnavailable {
                    self?.retry()
                } else {
                    self?.openGovUK()
                }
            }
        )
    }

    init(urlOpener: URLOpener = UIApplication.shared,
         error: AppUnavailableError? = nil,
         retryAction: @escaping (@escaping (Bool) -> Void) -> Void,
         dismissAction: @escaping () -> Void) {
        self.urlOpener = urlOpener
        self.error = error
        self.retryAction = retryAction
        self.dismissAction = dismissAction
        handleNetworkError()
    }

    private func handleNetworkError() {
        guard self.error == .networkUnavailable else { return }
        title = String.common.localized("networkUnavailableErrorTitle")
        subheading = String.common.localized("networkUnavailableErrorBody")
        buttonTitle = String.common.localized("networkUnavailableButtonTitle")
        buttonAccessibilityTitle = String.common.localized("networkUnavailableButtonTitle")
        buttonAccessibilityHint = ""
    }

    private func openGovUK() {
        urlOpener.openIfPossible(Constants.API.govukBaseUrl)
    }

    private func retry() {
        showProgressView = true
        retryAction { [weak self] wasSuccessful in
            if wasSuccessful {
                self?.dismissAction()
            }
            self?.showProgressView = false
        }
    }
}
