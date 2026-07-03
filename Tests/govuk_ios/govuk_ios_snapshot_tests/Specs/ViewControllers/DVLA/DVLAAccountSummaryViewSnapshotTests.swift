import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class DVLAAccountSummaryViewSnapshotTests: SnapshotTestCase {
    func test_vehicleTabSelected_light_rendersCorrectly() {
        let mockVehiclesViewModel = MockVehiclesViewModel(
            viewState: .loaded(
                vehicles: [
                    VehicleSummaryViewModel(
                        vehicle: .arrange,
                        detailAction: {}
                    )
                ]
            )
        )
        let mockLicenceViewModel = MockDrivingLicenceViewModel(
            viewState: .loaded(
                licence: DrivingLicenceSummaryViewModel(
                    driverSummary: .arrange,
                    statusBuilder: MockLicenceStatusViewModelBuilder(),
                    openURLAction: { _ in },
                    analyticsService: MockAnalyticsService()
                )
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

    func test_vehicleTabSelected_dark_rendersCorrectly() {
        let mockVehiclesViewModel = MockVehiclesViewModel(
            viewState: .loaded(
                vehicles: [
                    VehicleSummaryViewModel(
                        vehicle: .arrange,
                        detailAction: {}
                    )
                ]
            )
        )
        let mockLicenceViewModel = MockDrivingLicenceViewModel(
            viewState: .loaded(
                licence: DrivingLicenceSummaryViewModel(
                    driverSummary: .arrange,
                    statusBuilder: MockLicenceStatusViewModelBuilder(),
                    openURLAction: { _ in },
                    analyticsService: MockAnalyticsService()
                )
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

    func test_licenceTabSelected_dark_rendersCorrectly() {
        let mockVehiclesViewModel = MockVehiclesViewModel(
            viewState: .loaded(
                vehicles: [
                    VehicleSummaryViewModel(
                        vehicle: .arrange,
                        detailAction: {}
                    )
                ]
            )
        )
        let mockLicenceViewModel = MockDrivingLicenceViewModel(
            viewState: .loaded(
                licence: DrivingLicenceSummaryViewModel(
                    driverSummary: .arrange,
                    statusBuilder: MockLicenceStatusViewModelBuilder(),
                    openURLAction: { _ in },
                    analyticsService: MockAnalyticsService()
                )
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

    func test_licenceTabSelected_light_rendersCorrectly() {
        let mockVehiclesViewModel = MockVehiclesViewModel(
            viewState: .loaded(
                vehicles: [
                    VehicleSummaryViewModel(
                        vehicle: .arrange,
                        detailAction: {}
                    )
                ]
            )
        )
        let mockLicenceViewModel = MockDrivingLicenceViewModel(
            viewState: .loaded(
                licence: DrivingLicenceSummaryViewModel(
                    driverSummary: .arrange,
                    statusBuilder: MockLicenceStatusViewModelBuilder(),
                    openURLAction: { _ in },
                    analyticsService: MockAnalyticsService()
                )
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
}

