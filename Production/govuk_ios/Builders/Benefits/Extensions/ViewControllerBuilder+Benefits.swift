import Foundation
import GovKit
import SwiftUI
import UIKit

@MainActor
protocol BenefitsViewControllerBuilding: AnyObject {
    func makeBenefitsContainer() -> UIViewController
}

@MainActor
extension ViewControllerBuilder: BenefitsViewControllerBuilding {
    func makeBenefitsContainer(
    ) -> UIViewController {
        let viewModel = BenefitsContainerViewModel()
        let view = BenefitsContainerView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view
        )
        viewController.view.backgroundColor = .clear
        viewController.title = "Benefits"
        viewController.navigationItem.largeTitleDisplayMode = .always
        return viewController
    }
    func makeBenefitsLinkingAccountView(
    ) -> UIViewController {
        let view = BenefitsLinkingAccountview()
        let viewController = HostingViewController(
            rootView: view
        )
        viewController.view.backgroundColor = .clear
        viewController.navigationItem.largeTitleDisplayMode = .always
        return viewController
    }
}
