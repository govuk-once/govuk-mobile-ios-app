import SwiftUI
import GovKit

final class YourAccountsViewViewModel: ObservableObject {
    private let userService: UserServiceInterface
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

    init(userService: UserServiceInterface) {
        self.userService = userService
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

    @MainActor
    func unlinkAccount() {
        self.state = .loading
        userService.unlinkAccount(withType: .dvla) { [weak self] _ in
            self?.state = .empty
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
