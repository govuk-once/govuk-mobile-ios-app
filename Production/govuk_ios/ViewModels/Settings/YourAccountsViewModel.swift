import SwiftUI
import GovKit

final class YourAccountsViewViewModel: ObservableObject {
    private let userService: UserServiceInterface
    @Published var state: State = .loading
    let dismissAction: () -> Void
    let title = String(
        localized: .Settings.yourAccountsTitle
    )
    let errorViewDescription = String(
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
    func fetchAccountLinkStatus() async {
        let result = await userService.fetchAccountLinkStatus(
            accountType: .dvla
        )
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
