import UIKit
import Foundation
import GovKit

class LocalWasteScheduleCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let localWasteService: LocalWasteServiceInterface
    private let dismissed: () -> Void

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         localWasteService: LocalWasteServiceInterface,
         tintColor: UIColor = UIColor.govUK.text.link,
         dismissed: @escaping () -> Void) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.localWasteService = localWasteService
        self.dismissed = dismissed
        navigationController.navigationBar.tintColor = tintColor
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.localWasteScheduleView(
            analyticsService: analyticsService,
            localWasteService: localWasteService,
            dismissAction: { [weak self] in
                self?.dismissModal()
            }
        )
        set(viewController, animated: true)
    }

    private func dismissModal() {
        root.dismiss(
            animated: true,
            completion: { [weak self] in
                self?.finish()
            }
        )
    }

    override func finish() {
        super.finish()
        dismissed()
    }
}
