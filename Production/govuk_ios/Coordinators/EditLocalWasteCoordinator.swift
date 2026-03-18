import UIKit
import Foundation
import GovKit

class EditLocalWasteCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let localWasteService: LocalWasteServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder
    private let addressSelectedAction: () -> Void
    private let dismissed: () -> Void

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         localWasteService: LocalWasteServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         tintColor: UIColor = UIColor.govUK.text.link,
         addressSelectedAction: @escaping () -> Void,
         dismissed: @escaping () -> Void) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.localWasteService = localWasteService
        self.coordinatorBuilder = coordinatorBuilder
        self.addressSelectedAction = addressSelectedAction
        self.dismissed = dismissed
        navigationController.navigationBar.tintColor = tintColor
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.localWastePostcodeEntryView(
            analyticsService: analyticsService,
            localWasteService: localWasteService,
            dismissAction: { [weak self] in
                self?.dismissModal()
            },
            doneAction: { [weak self] (addresses) in
                self?.navigateToAddressView(addresses: addresses)
            }
        )
        set(viewController, animated: true)
    }

    private func navigateToAddressView(addresses: [LocalWasteAddress]) {
        let viewController = viewControllerBuilder.localWasteAddressSelectionView(
            analyticsService: analyticsService,
            localWasteService: localWasteService,
            addresses: addresses,
            dismissAction: { [weak self] in
                self?.dismissModal()
            },
            doneAction: { [weak self] in
                self?.addressSelectedAction()
                self?.dismissModal()
            }
        )
        push(viewController, animated: true)
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
