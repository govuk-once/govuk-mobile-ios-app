import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class DVLAAccountWidgetViewSnapshotTests: SnapshotTestCase {
    func test_linkAccountCard_light_rendersCorrectly() {
        let viewModel = makeUnlinkedStateViewModel()
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
        let viewModel = makeUnlinkedStateViewModel()
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

    func test_accountSummaryView_light_rendersCorrectly() {
        let viewModel = makeLinkedStateViewModel()
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

    func test_accountSummaryView_dark_rendersCorrectly() {
        let viewModel = makeLinkedStateViewModel()
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

    private func makeUnlinkedStateViewModel() -> MockDVLAAccountWidgetViewModel {
        let linkCardViewModel = ServiceAccountLinkCardViewModel(
            title: "Add driver and vehicles account",
            subtitle: "Your tax, MOT, penalty points",
            action: {}
        )
        return MockDVLAAccountWidgetViewModel(viewState: .unlinked(linkCard: linkCardViewModel))
    }

    private func makeLinkedStateViewModel() -> MockDVLAAccountWidgetViewModel {
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            registrationNumber: "AB12 CDE",
            make: "LAND ROVER RANGE ROVER",
            model: "SPORT 2.0 TD4 HSE DYNAMIC",
            taxedUntil: .arrange("01/12/2027"),
            motExpiryDate: .arrange("01/08/2027")
        )

        let mockVehiclesViewModel = MockVehiclesViewModel(
            viewState: .loaded(
                vehicles: [
                    VehicleSummaryViewModel(
                        vehicle: mockVehicle,
                        detailAction: {},
                        openURLAction: { _ in },
                        configService: MockAppConfigService(),
                        analyticsService: MockAnalyticsService()
                    )
                ]
            )
        )
        let mockLicenceViewModel = MockDrivingLicenceViewModel(
            viewState: .loaded(
                licence: DrivingLicenceSummaryViewModel(
                    drivingLicence: .arrange,
                    statusBuilder: MockLicenceStatusViewModelBuilder(),
                    openURLAction: { _, _ in }
                )
            )
        )
        let mockAccountSummaryViewModel = MockDVLAAccountSummaryViewModel(
            vehiclesViewModel: mockVehiclesViewModel,
            licenceViewModel: mockLicenceViewModel
        )
        return MockDVLAAccountWidgetViewModel(
            viewState: .linked(accountSummary: mockAccountSummaryViewModel)
        )
    }
}

extension DVLAAccountWidgetViewModel.Actions {
    static var empty: DVLAAccountWidgetViewModel.Actions {
        .init(
            linkAction: {},
            vehicleDetailAction: { _ in },
            openURLAction: { _ in }
        )
    }
}
