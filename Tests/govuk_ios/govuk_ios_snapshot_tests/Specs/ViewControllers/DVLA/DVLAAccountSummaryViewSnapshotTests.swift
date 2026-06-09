import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class DVLAAccountSummaryViewSnapshotTests: SnapshotTestCase {
    func test_vehiclesAndLicenceView_light_rendersCorrectly() {
        let mockVehiclesViewModel = MockVehiclesViewModel(
            viewState: .loaded(
                vehicles: [
                    VehicleSummaryViewModel(vehicle: .arrange)
                ]
            )
        )
        let mockLicenceViewModel = MockDrivingLicenceViewModel(
            viewState: .loaded(
                licence: DrivingLicenceSummaryViewModel(driverSummary: .arrange)
            )
        )
        let viewModel = MockDVLAAccountSummaryViewModel(
            vehiclesViewModel: mockVehiclesViewModel,
            licenceViewModel: mockLicenceViewModel
        )
        let view = DVLAAccountSummaryView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }
}

