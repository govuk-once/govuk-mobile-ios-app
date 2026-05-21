import Foundation
import UIKit
import GovKit

final class ServiceAccountLinkingViewModel: ObservableObject {
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let urlOpener: URLOpener
    private let accountType: ServiceAccountType
    private let linkId: String
    private let completeAction: () -> Void
    private let dismissAction: () -> Void
    @Published var showProgressView: Bool = false
    @Published private(set) var errorViewModel: ErrorViewModel?

    init(analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         urlOpener: URLOpener = UIApplication.shared,
         accountType: ServiceAccountType,
         linkId: String,
         completeAction: @escaping () -> Void,
         dismissAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.userService = userService
        self.urlOpener = urlOpener
        self.accountType = accountType
        self.linkId = linkId
        self.completeAction = completeAction
        self.dismissAction = dismissAction
    }

    private var accountName: String {
        accountType == .dvla ? String.dvla.localized("accountName") : ""
    }

    var title: String {
        let format = String.serviceAccount.localized("accountLinkingTitle")
        return String.localizedStringWithFormat(format, accountName)
    }

    func linkAccount() {
        showProgressView = true
        errorViewModel = nil
        userService.linkAccount(
            withType: accountType,
            linkId: linkId
        ) { [weak self] result in
            self?.showProgressView = false
            switch result {
            case .success:
                self?.completeAction()
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }

    func dismiss() {
        dismissAction()
    }

    private func openGovUK() {
        urlOpener.openIfPossible(Constants.API.govukBaseUrl)
    }

    private func handleError(_ error: UserStateError) {
        errorViewModel = (error == .networkUnavailable)
        ? internetConnectionErrorViewModel
        : accountLinkingErrorViewModel
    }

    private var accountLinkingErrorViewModel: ErrorViewModel {
        let subtitleFormat = String.serviceAccount.localized("accountLinkingErrorSubtitle")
        let subtitle = String.localizedStringWithFormat(subtitleFormat, accountName)
        return ErrorViewModel(
            analyticsService: analyticsService,
            title: String.common.localized("genericErrorTitle"),
            subtitle: subtitle,
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: .dvla
                .localized("accountLinkingErrorPrimaryButtonTitle"),
            primaryAction: dismissAction,
            secondaryButtonTitle: .serviceAccount
                .localized("accountLinkingErrorSecondaryButtonTitle"),
            secondaryAction: openGovUK,
            trackingName: "Account linking error"
        )
    }

    private var internetConnectionErrorViewModel: ErrorViewModel {
        ErrorViewModel(
            analyticsService: analyticsService,
            title: String.common.localized("networkUnavailableErrorTitle"),
            subtitle: String.common.localized("networkUnavailableErrorBody"),
            primaryButtonTitle: String.common.localized("networkUnavailableButtonTitle"),
            primaryAction: linkAccount,
            contentAlignment: .topLeading,
            trackingName: "Internet connection error"
        )
    }
}
