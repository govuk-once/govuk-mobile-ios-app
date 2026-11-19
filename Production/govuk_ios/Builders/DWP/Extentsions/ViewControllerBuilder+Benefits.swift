import Foundation
import GovKit
import SwiftUI
import UIKit

@MainActor
protocol BenefitsViewControllerBuilding: AnyObject {
    func makeBenefitsContainer(
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface,
    ) -> UIViewController
}

@MainActor
extension ViewControllerBuilder: BenefitsViewControllerBuilding {
    func makeBenefitsContainer(
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface,
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
}
