import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class LocalWastePostcodeEntryViewControllerSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_error_light_rendersCorrectly() async {

        let viewModel = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in },
        )
        let view = LocalWastePostcodeEntryView(
            viewModel: viewModel
        )
        viewModel.postcode = ""
        await viewModel.fetchAddresses()
        let viewController = HostingViewController(
            rootView: view,
            navigationBarHidden: true
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_error_dark_rendersCorrectly() async {

        let viewModel = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in },
        )
        let view = LocalWastePostcodeEntryView(
            viewModel: viewModel
        )
        viewModel.postcode = ""
        await viewModel.fetchAddresses()
        let viewController = HostingViewController(
            rootView: view,
            navigationBarHidden: true
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    private func viewController() -> UIViewController {
        let viewModel = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        let view = LocalWastePostcodeEntryView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view,
            navigationBarHidden: true
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        return viewController
    }
}


