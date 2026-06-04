import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class DVLAAccountSummaryViewSnapshotTests: SnapshotTestCase {
    func test_vehiclesLoadingView_light_rendersCorrectly() {
        let viewModel = MockDVLAAccountSummaryViewModel(
            viewState: .loading
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

    func test_vehiclesLoadingView_dark_rendersCorrectly() {
        let viewModel = MockDVLAAccountSummaryViewModel(
            viewState: .loading
        )
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

    func test_vehicleSummaryView_light_rendersCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            registrationNumber: "AB12 CDE",
            make: "LAND ROVER RANGE ROVER",
            model: "SPORT 2.0 TD4 HSE DYNAMIC",
            taxedUntil: Date(timeIntervalSince1970: 1779975444),
            motExpiryDate: Date(timeIntervalSince1970: 1779975444)
        )

        let viewModel = MockDVLAAccountSummaryViewModel(
            viewState: .loaded(vehicles: [VehicleSummaryViewModel(vehicle: mockVehicle)])
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

    func test_vehicleSummaryView_dark_rendersCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            registrationNumber: "AB12 CDE",
            make: "LAND ROVER RANGE ROVER",
            model: "SPORT 2.0 TD4 HSE DYNAMIC",
            taxedUntil: Date(timeIntervalSince1970: 1779975444),
            motExpiryDate: Date(timeIntervalSince1970: 1779975444)
        )
        let viewModel = MockDVLAAccountSummaryViewModel(
            viewState: .loaded(vehicles: [VehicleSummaryViewModel(vehicle: mockVehicle)])
        )
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

    func test_errorView_light_rendersCorrectly() {
        let errorViewModel = AppErrorViewModel(
            title: "Test error",
            body: "Something went wrong.",
            buttonTitle: "Try again"
        )

        let viewModel = MockDVLAAccountSummaryViewModel(
            viewState: .error(errorViewModel)
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

    func test_errorView_dark_rendersCorrectly() {
        let errorViewModel = AppErrorViewModel(
            title: "Test error",
            body: "Something went wrong.",
            buttonTitle: "Try again"
        )

        let viewModel = MockDVLAAccountSummaryViewModel(
            viewState: .error(errorViewModel)
        )
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
}

