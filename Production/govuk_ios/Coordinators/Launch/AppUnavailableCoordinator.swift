import Foundation
import UIKit
import SwiftUI

class AppUnavailableCoordinator: BaseCoordinator {
    private let error: AppUnavailableError?
    let dismissAction: () -> Void
    let retryAction: (@escaping (Bool) -> Void) -> Void

    init(navigationController: UINavigationController,
         error: AppUnavailableError?,
         retryAction: @escaping (@escaping (Bool) -> Void) -> Void,
         dismissAction: @escaping () -> Void) {
        self.error = error
        self.retryAction = retryAction
        self.dismissAction = dismissAction
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        guard let error = error
        else { return dismissAction() }
        setAppUnavailable(error)
    }

    private func setAppUnavailable(_ error: AppUnavailableError?) {
        let viewModel = AppUnavailableContainerViewModel(
            error: error,
            retryAction: retryAction,
            dismissAction: dismissAction
        )
        let containerView = AppUnavailableContainerView(
            viewModel: viewModel
        )
        let viewController = UIHostingController(
            rootView: containerView
        )
        set(viewController)
    }
}
