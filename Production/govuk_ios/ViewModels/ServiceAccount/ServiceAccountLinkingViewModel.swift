import Foundation
import GovKit

final class ServiceAccountLinkingViewModel: ObservableObject {
    private let userService: UserServiceInterface
    private let accountType: ServiceAccountType
    private let linkId: String
    private let completeAction: () -> Void
    private let dismissAction: () -> Void
    @Published var showProgressView: Bool = false
    @Published private(set) var errorViewModel: AppErrorViewModel?

    init(userService: UserServiceInterface,
         accountType: ServiceAccountType,
         linkId: String,
         completeAction: @escaping () -> Void,
         dismissAction: @escaping () -> Void) {
        self.userService = userService
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
            case .failure:
                self?.errorViewModel = self?.accountLinkingErrorViewModel
            }
        }
    }

    func dismiss() {
        dismissAction()
    }

    private var accountLinkingErrorViewModel: AppErrorViewModel {
        AppErrorViewModel.serviceAccountLinkingErrorWithAction { [weak self] in
            self?.linkAccount()
        }
    }
}
