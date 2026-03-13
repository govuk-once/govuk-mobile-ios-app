import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class LocalWasteAddressSelectionViewControllerSnapshotTests: SnapshotTestCase {
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

    private func viewController() -> UIViewController {
        let addresses = [
            LocalWasteAddress(
                addressFull: "12, KYNASTON VIEW, HANHAM, BRISTOL, BS15 3FL",
                uprn: "662553",
                localCustodianCode: "119"
            ),
            LocalWasteAddress(
                addressFull: "14, KYNASTON VIEW, HANHAM, BRISTOL, BS15 3FL",
                uprn: "662554",
                localCustodianCode: "119"
            ),
            LocalWasteAddress(
                addressFull: "15, KYNASTON VIEW, HANHAM, BRISTOL, BS15 3FL",
                uprn: "662564",
                localCustodianCode: "119"
            ),
            LocalWasteAddress(
                addressFull: "16, KYNASTON VIEW, HANHAM, BRISTOL, BS15 3FL",
                uprn: "662555",
                localCustodianCode: "119"
            )
        ]

        let viewModel = LocalWasteAddressSelectionViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            addresses: addresses,
            dismissAction: { }
        )

        let view = LocalWasteAddressSelectionView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        return viewController
    }
}
