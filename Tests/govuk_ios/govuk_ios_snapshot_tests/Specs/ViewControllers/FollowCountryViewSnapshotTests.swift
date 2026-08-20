import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
final class FollowCountryViewSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_light_rendersCorrectly() {
        let viewModel = makeViewModel()
        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        let viewModel = makeViewModel()
        let viewController = makeViewController(viewModel: viewModel)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    private func makeViewModel() -> FollowCountryViewModel {
        let mockTravelService = MockTravelService()
        return FollowCountryViewModel(
            travelService: mockTravelService,
            dismissAction: { /*EmptyForTests*/ }
        )
    }

    private func makeViewController(viewModel: FollowCountryViewModel) -> UIViewController {
        let view = FollowCountryView(viewModel: viewModel)
        let viewController = HostingViewController(rootView: view)
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        return viewController
    }
}
