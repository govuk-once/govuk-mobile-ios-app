import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class DVLAAccountWidgetViewSnapshotTests: SnapshotTestCase {
    func test_linkAccountCard_light_rendersCorrectly() {
        let linkCardViewModel = ServiceAccountLinkCardViewModel(
            title: "Add driver and vehicles account",
            subtitle: "Your tax, MOT, penalty points",
            action: {}
        )
        let viewModel = MockDVLAAccountWidgetViewModel(viewState: .unlinked(linkCard: linkCardViewModel))
        let view = DVLAAccountWidgetView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_linkAccountCard_dark_rendersCorrectly() {
        let linkCardViewModel = ServiceAccountLinkCardViewModel(
            title: "Add driver and vehicles account",
            subtitle: "Your tax, MOT, penalty points",
            action: {}
        )
        let viewModel = MockDVLAAccountWidgetViewModel(viewState: .unlinked(linkCard: linkCardViewModel))
        let view = DVLAAccountWidgetView(viewModel: viewModel)
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
        let mockAccountSummaryViewModel = MockDVLAAccountSummaryViewModel(
            viewState: .loaded(
                vehicles: [
                    VehicleSummaryViewModel(vehicle: mockVehicle)
                ]
            )
        )
        let viewModel = MockDVLAAccountWidgetViewModel(viewState: .linked(actionCards: [], accountSummary: mockAccountSummaryViewModel))
        let view = DVLAAccountWidgetView(viewModel: viewModel)
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
        let mockAccountSummaryViewModel = MockDVLAAccountSummaryViewModel(
            viewState: .loaded(
                vehicles: [
                    VehicleSummaryViewModel(vehicle: mockVehicle)
                ]
            )
        )
        let viewModel = MockDVLAAccountWidgetViewModel(viewState: .linked(actionCards: [], accountSummary: mockAccountSummaryViewModel))
        let view = DVLAAccountWidgetView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_error_light_rendersCorrectly() {
        let errorViewModel = AppErrorViewModel(
            title: "Something went wrong",
            body: "Try again later",
            buttonTitle: "Try again"
        )
        let viewModel = MockDVLAAccountWidgetViewModel(viewState: .error(errorViewModel))
        let view = DVLAAccountWidgetView(viewModel: viewModel)
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

extension DVLAAccountWidgetViewModel.Actions {
    static var empty: DVLAAccountWidgetViewModel.Actions {
        .init(
            linkAction: {},
            unlinkAction: {},
            viewDriverSummaryAction: {},
            viewCustomerSummaryAction: {},
            viewVehicleAction: {},
            viewShareCodesAction: {},
            createShareCodeAction: {}
        )
    }
}
