import Foundation
import UIKit
import GovKit

final class ServiceAccountLinkingViewModel: ObservableObject {
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let urlOpener: URLOpener
    private let accountType: ServiceAccountType
    private let token: String
    private let completeAction: () -> Void
    private let dismissAction: () -> Void
    @Published var showProgressView: Bool = false
    @Published private(set) var errorViewModel: ErrorViewModel?

    init(analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         urlOpener: URLOpener = UIApplication.shared,
         accountType: ServiceAccountType,
         token: String,
         completeAction: @escaping () -> Void,
         dismissAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.userService = userService
        self.urlOpener = urlOpener
        self.accountType = accountType
        self.token = token
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
            token: token
        ) { [weak self] result in
            guard let self = self else { return }
            self.showProgressView = false
            switch result {
            case .success:
                self.completeAction()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }

    func dismiss() {
        dismissAction()
    }

    private func handleError(_ error: UserStateError) {
        errorViewModel = (error == .networkUnavailable)
        ? internetConnectionErrorViewModel
        : accountLinkingErrorViewModel
    }

    private func trackNavigation(
        text: String,
        external: Bool,
        url: String?,
        section: String?
    ) {
        let event = AppEvent.buttonNavigation(
            text: text,
            external: external,
            url: url,
            section: section
        )
        analyticsService.track(event: event)
    }

    private var accountLinkingErrorViewModel: ErrorViewModel {
        let screenTitle = String.common.localized("genericErrorTitle")
        let primaryButtonTitle = String.dvla
            .localized("accountLinkingErrorPrimaryButtonTitle")
        let secondaryButtonTitle = String.serviceAccount
            .localized("accountLinkingErrorSecondaryButtonTitle")
        let subtitleFormat = String.serviceAccount.localized("accountLinkingErrorSubtitle")
        let subtitle = String.localizedStringWithFormat(subtitleFormat, accountName)

        return ErrorViewModel(
            analyticsService: analyticsService,
            title: screenTitle,
            subtitle: subtitle,
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: primaryButtonTitle,
            primaryAction: { [weak self] in
                self?.handleLinkingErrorPrimaryAction(title: primaryButtonTitle)
            },
            secondaryButtonTitle: secondaryButtonTitle,
            secondaryAction: { [weak self] in
                self?.handleLinkingErrorSecondaryAction(title: secondaryButtonTitle)
            },
            trackingName: screenTitle,
        )
    }

    private func handleLinkingErrorPrimaryAction(title: String) {
        trackNavigation(
            text: title,
            external: false,
            url: nil,
            section: "account link fail"
        )
        dismissAction()
    }

    private func handleLinkingErrorSecondaryAction(title: String) {
        let url = Constants.API.govukBaseUrl
        trackNavigation(
            text: title,
            external: true,
            url: url.absoluteString,
            section: "account link fail"
        )
        urlOpener.openIfPossible(url)
    }

    private var internetConnectionErrorViewModel: ErrorViewModel {
        let screenTitle = String.common.localized("networkUnavailableErrorTitle")
        let buttonTitle = String.common.localized("networkUnavailableButtonTitle")
        return ErrorViewModel(
            analyticsService: analyticsService,
            title: screenTitle,
            subtitle: String.common.localized("networkUnavailableErrorBody"),
            primaryButtonTitle: buttonTitle,
            primaryAction: { [weak self] in
                self?.handleConnectionErrorPrimaryAction(title: buttonTitle)
            },
            contentAlignment: .topLeading,
            trackingName: screenTitle,
        )
    }

    private func handleConnectionErrorPrimaryAction(title: String) {
        trackNavigation(
            text: title,
            external: false,
            url: nil,
            section: "account link fail"
        )
        linkAccount()
    }
}
