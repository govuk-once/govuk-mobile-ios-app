import SwiftUI
import GovKit

final class YourAccountsViewViewModel: ObservableObject {
    private let userService: UserServiceInterface
    private var analyticsService: AnalyticsServiceInterface
    let unlinkErrorViewModel = UnlinkAccountsErrorViewModel()
    @Published var showingUnlinkError: Bool = false
    @Published var state: State = .loading
    let title = String(
        localized: .Settings.yourAccountsTitle
    )
    let emptyViewDescription = String(
        localized: .Settings.yourAccountsErrorViewDesc
    )
    let yourAccountsCardTitle = String(
        localized: .Settings.yourAccountsCardTitle
    )
    let editButtonTitle = String(
        localized: .Settings.yourAccountsViewEditButtonTitle
    )
    let backButtonAccessibilityLabel = String(
        localized: .Settings.yourAccountsBackButtonLabel
    )
    let failureViewTitle = String(
        localized: .Settings.yourAccountsFailureViewTitle
    )
    let failureViewDescription = String(
        localized: .Settings.yourAccountsfailureViewDescription
    )
    let alertMessageTitle =  String(
        localized: .Settings.yourAccountsAlertButtonTitle
    )
    let alertRemoveButtonTitle = String(
        localized: .Settings.yourAccountsAlertRemoveButtonTitle
    )
    let alertCancelButtonTitle = String(
        localized: .Settings.yourAccountsAlertCancelButtonTitle
    )
    let alertMessage = String(
        localized: .Settings.yourAccountsAlertMessage
    )
    let editModeAccessibilityText = String(
        localized: .Settings.yourAccountsEditModeAccessibilityText
    )
    let editModeDoneButton = String(
        localized: .Settings.yourAccountsEditModeDoneButton
    )

    init(userService: UserServiceInterface,
         analyticsService: AnalyticsServiceInterface) {
        self.userService = userService
        self.analyticsService = analyticsService
    }

    enum State {
        case loading
        case empty
        case success
        case failure
    }

    @MainActor
    func fetchLinkedAccounts() async {
        if let isDvlaAccountLinked = userService.linkedAccounts?.contains(.dvla) {
            updateState(isAccountLinked: isDvlaAccountLinked)
        } else {
            let result = await userService.fetchLinkedAccounts()
            switch result {
            case .success(let linkedAccounts):
                let isDvlaAccountLinked = linkedAccounts.contains(.dvla)
                updateState(isAccountLinked: isDvlaAccountLinked)
            case .failure:
                self.state = .failure
            }
        }
    }

    func trackNavigationEvent(text: String) {
        let event = AppEvent.buttonNavigation(
            text: text,
            external: false,
            section: "settings"
        )
        analyticsService.track(event: event)
    }

    func trackEvent(text: String) {
        let event = AppEvent.function(
            text: text,
            type: "Button",
            section: "Settings",
            action: ""
        )
        analyticsService.track(event: event)
    }

    @MainActor
    func unlinkAccount() {
        self.state = .loading
        userService.unlinkAccount(withType: .dvla) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.state = .empty
            case .failure:
                self.showingUnlinkError = true
            }
        }
    }

    @MainActor
    func updateState(isAccountLinked: Bool) {
        if isAccountLinked {
            self.state = .success
        } else {
            self.state = .empty
        }
    }
}
