import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class BenefitsContainerViewControllerSnapshotTests: SnapshotTestCase {
    func test_benefitsContainerView_light_rendersCorrectly() {
        let viewModel = BenefitsContainerViewModel()
        let view = BenefitsContainerView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light
        )
    }
    
    func test_benefitsContainerView_dark_rendersCorrectly() {
        let viewModel = BenefitsContainerViewModel()
        let view = BenefitsContainerView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark
        )
    }
}

