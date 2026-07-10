import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class VehiclesViewSnapshotTests: SnapshotTestCase {
    func test_loadingView_light_rendersCorrectly() {
        let viewModel = MockVehiclesViewModel(
            viewState: .loading
        )
        let view = VehiclesView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_loadingView_dark_rendersCorrectly() {
        let viewModel = MockVehiclesViewModel(
            viewState: .loading
        )
        let view = VehiclesView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_vehicleSummaryView_emptyVehicles_light_rendersCorrectly() {
        let viewModel = MockVehiclesViewModel(
            viewState: .loaded(vehicles: [])
        )
        let view = VehiclesView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_vehicleSummaryView_emptyVehicles_dark_rendersCorrectly() {
        let viewModel = MockVehiclesViewModel(
            viewState: .loaded(vehicles: [])
        )
        let view = VehiclesView(viewModel: viewModel)
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
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            registrationNumber: "AB12 CDE",
            make: "LAND ROVER RANGE ROVER",
            model: "SPORT 2.0 TD4 HSE DYNAMIC",
            taxedUntil: Date(timeIntervalSince1970: 1779975444),
            motExpiryDate: Date(timeIntervalSince1970: 1779975444)
        )

        let viewModel = MockVehiclesViewModel(
            viewState: .loaded(
                vehicles: [
                    CustomerVehicleViewModel(
                        vehicle: mockVehicle,
                        detailAction: {},
                        openURLAction: { _ in },
                        configService: MockAppConfigService(),
                        analyticsService: MockAnalyticsService()
                    )
                ]
            )
        )
        let view = VehiclesView(viewModel: viewModel)
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
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            registrationNumber: "AB12 CDE",
            make: "LAND ROVER RANGE ROVER",
            model: "SPORT 2.0 TD4 HSE DYNAMIC",
            taxedUntil: Date(timeIntervalSince1970: 1779975444),
            motExpiryDate: Date(timeIntervalSince1970: 1779975444)
        )
        let viewModel = MockVehiclesViewModel(
            viewState: .loaded(
                vehicles: [
                    CustomerVehicleViewModel(
                        vehicle: mockVehicle,
                        detailAction: {},
                        openURLAction: { _ in },
                        configService: MockAppConfigService(),
                        analyticsService: MockAnalyticsService()
                    )
                ]
            )
        )
        let view = VehiclesView(viewModel: viewModel)
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
        let errorViewModel = InlineActionErrorViewModel(
            title: "Test error",
            markdownBody: "Try again later or [go to the website](https://gov.uk)",
            openURLAction: { _ in }
        )

        let viewModel = MockVehiclesViewModel(
            viewState: .error(errorViewModel)
        )
        let view = VehiclesView(viewModel: viewModel)
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
        let errorViewModel = InlineActionErrorViewModel(
            title: "Test error",
            markdownBody: "Try again later or [go to the website](https://gov.uk)",
            openURLAction: { _ in }
        )

        let viewModel = MockVehiclesViewModel(
            viewState: .error(errorViewModel)
        )
        let view = VehiclesView(viewModel: viewModel)
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
