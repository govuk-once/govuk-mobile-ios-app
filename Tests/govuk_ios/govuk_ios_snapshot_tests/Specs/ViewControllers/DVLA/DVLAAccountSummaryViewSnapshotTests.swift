import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class DVLAAccountSummaryViewSnapshotTests: SnapshotTestCase {
<<<<<<< HEAD
    func test_vehicleTabSelected_light_rendersCorrectly() {
=======
    func test_vehiclesAndLicenceView_light_rendersCorrectly() {
>>>>>>> feature/dvla
        let mockVehiclesViewModel = MockVehiclesViewModel(
            viewState: .loaded(
                vehicles: [
                    VehicleSummaryViewModel(vehicle: .arrange)
                ]
            )
<<<<<<< HEAD
=======
        )
        let mockLicenceViewModel = MockDrivingLicenceViewModel(
            viewState: .loaded(
                licence: DrivingLicenceSummaryViewModel(driverSummary: .arrange)
            )
        )
        let viewModel = MockDVLAAccountSummaryViewModel(
            vehiclesViewModel: mockVehiclesViewModel,
            licenceViewModel: mockLicenceViewModel
>>>>>>> feature/dvla
        )
        let mockLicenceViewModel = MockDrivingLicenceViewModel(
            viewState: .loaded(
                licence: DrivingLicenceSummaryViewModel(driverSummary: .arrange)
            )
        )
        let viewModel = DVLAAccountSummaryViewModel(
            vehiclesViewModel: mockVehiclesViewModel,
            licenceViewModel: mockLicenceViewModel
        )
        viewModel.selectedScreen = .vehicles
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
<<<<<<< HEAD

    func test_vehicleTabSelected_dark_rendersCorrectly() {
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
        let viewModel = DVLAAccountSummaryViewModel(
            vehiclesViewModel: mockVehiclesViewModel,
            licenceViewModel: mockLicenceViewModel
        )
        viewModel.selectedScreen = .vehicles
        let view = DVLAAccountSummaryView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_licenceView_dark_rendersCorrectly() {
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

        let viewModel = DVLAAccountSummaryViewModel(
            vehiclesViewModel: mockVehiclesViewModel,
            licenceViewModel: mockLicenceViewModel
        )
        viewModel.selectedScreen = .drivingLicence
        let view = DVLAAccountSummaryView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_licenceView_light_rendersCorrectly() {
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

        let viewModel = DVLAAccountSummaryViewModel(
            vehiclesViewModel: mockVehiclesViewModel,
            licenceViewModel: mockLicenceViewModel
        )
        viewModel.selectedScreen = .drivingLicence
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
=======
>>>>>>> feature/dvla
}

