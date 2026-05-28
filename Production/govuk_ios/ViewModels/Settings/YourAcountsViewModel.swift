import SwiftUI
import GovKit
import LocalAuthentication

final class YourAccountsViewViewModel: ObservableObject {
    private var userService: UserServiceInterface
    @Published var state: State = .loading
    let dismissAction: () -> Void
    let title = String(localized: .Settings.linkAccountsTitle)
    let errorViewDescription = String(localized: .Settings.yourAccountsErrorViewDesc)
    let yourAccountsCardTitle = String(localized: .Settings.yourAccountsCardTitle)
    let editButtonTitle = String(localized: .Settings.yourAccountsViewEditButtonTitle)

    init(userService: UserServiceInterface,
         dismissAction: @escaping () -> Void) {
        self.userService = userService
        self.dismissAction = dismissAction
    }

    enum State {
        case loading
        case success
        case failure
    }

    @MainActor
    func fetchLinkStatus() async {
        let result = await userService.fetchAccountLinkStatus(accountType: .dvla)
        switch result {
        case .success(let status):
            if status.linked == true {
                self.state = .success
            }
        case .failure:
            self.state = .failure
        }
    }
}
