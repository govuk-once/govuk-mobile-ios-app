import Foundation
import GovKit

final class ServiceAccountUnlinkingViewModel: ObservableObject, ProgressIndicating {
    private let userService: UserServiceInterface
    private let accountType: ServiceAccountType
    private let completeAction: () -> Void
    private let dismissAction: () -> Void
    @Published var showProgressView: Bool = false
    @Published private(set) var errorViewModel: AppErrorViewModel?

    var animationDelay: TimeInterval {
        showProgressView ? 1.0 : 0.0
    }

    var accessibilityLabel: String {
        String.serviceAccount.localized("unlinkingLoadingIndicatorAccessibilityTitle")
    }

    init(userService: UserServiceInterface,
         accountType: ServiceAccountType,
         completeAction: @escaping () -> Void,
         dismissAction: @escaping () -> Void) {
        self.userService = userService
        self.accountType = accountType
        self.completeAction = completeAction
        self.dismissAction = dismissAction
    }

    func unlinkAccount() {
        showProgressView = true
        errorViewModel = nil
        userService.unlinkAccount(
            withType: accountType,
        ) { [weak self] result in
            self?.showProgressView = false
            switch result {
            case .success:
                self?.completeAction()
            case .failure:
                self?.errorViewModel = self?.accountUnlinkingErrorViewModel
            }
        }
    }

    func dismiss() {
        dismissAction()
    }

    private var accountUnlinkingErrorViewModel: AppErrorViewModel {
        AppErrorViewModel.serviceAccountUnlinkingErrorWithAction { [weak self] in
            self?.unlinkAccount()
        }
    }
}
