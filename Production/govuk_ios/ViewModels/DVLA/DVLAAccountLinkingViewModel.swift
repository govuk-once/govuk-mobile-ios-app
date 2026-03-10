import Foundation
import GovKit

final class DVLAAccountLinkingViewModel: ObservableObject, ProgressIndicating {
    private let dvlaService: DVLAServiceInterface
    private let linkId: String
    private let completeAction: () -> Void
    private let dismissAction: () -> Void
    @Published var showProgressView: Bool = false
    @Published private(set) var errorViewModel: AppErrorViewModel?

    var animationDelay: TimeInterval {
        showProgressView ? 1.0 : 0.0
    }

    var accessibilityLabel: String {
        String.onboarding.localized("loadingIndicatorAccessibilityTitle")
    }

    init(dvlaService: DVLAServiceInterface,
         linkId: String,
         completeAction: @escaping () -> Void,
         dismissAction: @escaping () -> Void) {
        self.dvlaService = dvlaService
        self.linkId = linkId
        self.completeAction = completeAction
        self.dismissAction = dismissAction
    }

    func linkAccount() {
        showProgressView = true
        errorViewModel = nil
        dvlaService.linkAccount(linkId: linkId) { [weak self] result in
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
        AppErrorViewModel.dvlaAccountErrorWithAction { [weak self] in
            self?.linkAccount()
        }
    }
}
