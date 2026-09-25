import Foundation
import GovKit
import GovKitUI

class TravelAlertsPermissionViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loading
    }

    @Published private(set) var viewState: ViewState = .idle

    private let travelService: TravelServiceInterface
    let analyticsService: AnalyticsServiceInterface
    let dismissSheetAction: () -> Void
    let openURLAction: (URL) -> Void
    let showImage: Bool

    let title: String
    let body: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String
    let privacyPolicyLinkTitle: String

    private var countryToProcess: Country?
    private var dismissAfterSuccessAction: (() -> Void)?
    private var dismissAfterErrorAction: (() -> Void)?

    init(
        travelService: TravelServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        showImage: Bool = true,
        title: String,
        body: String,
        primaryButtonTitle: String,
        secondaryButtonTitle: String,
        privacyPolicyLinkTitle: String = String(
            localized: .Travel.travelAlertPermissionPrivacyButtonTitle
        ),
        country: Country,
        dismissSheetAction: @escaping () -> Void,
        openURLAction: @escaping (URL) -> Void,
        dismissAfterSuccessAction: @escaping () -> Void,
        dismissAfterErrorAction: @escaping () -> Void
    ) {
        self.travelService = travelService
        self.analyticsService = analyticsService
        self.showImage = showImage
        self.title = title
        self.body = body
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.privacyPolicyLinkTitle = privacyPolicyLinkTitle
        self.countryToProcess = country
        self.dismissSheetAction = dismissSheetAction
        self.openURLAction = openURLAction
        self.dismissAfterSuccessAction = dismissAfterSuccessAction
        self.dismissAfterErrorAction = dismissAfterErrorAction
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: primaryButtonTitle,
            action: { [weak self] in
                self?.allowNotificationsAction()
            }
        )
    }

    var secondaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: secondaryButtonTitle,
            action: { [weak self] in
                self?.notNowAction()
            }
        )
    }

    func allowNotificationsAction() {
        subscribeToCountry(notificationsEnabled: true)
    }

    func notNowAction() {
        subscribeToCountry(notificationsEnabled: false)
    }

    private func subscribeToCountry(notificationsEnabled: Bool) {
        guard let country = countryToProcess else { return }
        viewState = .loading

        travelService.subscribeToCountry(
            slug: country.slug,
            notificationsEnabled: notificationsEnabled,
            completion: { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success:
                        self?.viewState = .idle
                        self?.dismissAfterSuccessAction?()
                    case .failure(let error):
                        self?.dismissAfterErrorAction?()
                    }
                }
            }
        )
    }

    func openPrivacyPolicy() {
        let privacyPolicyURL = URL(string: Constants.API.privacyPolicyUrl.absoluteString)
        if let url = privacyPolicyURL {
            openURLAction(url)
        }
    }
}
