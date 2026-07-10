import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class DrivingLicenceViewSnapshotTests: SnapshotTestCase {
    func test_loadingView_light_rendersCorrectly() {
        let viewModel = MockDrivingLicenceViewModel(
            viewState: .loading
        )
        let view = DrivingLicenceView(viewModel: viewModel)
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
        let viewModel = MockDrivingLicenceViewModel(
            viewState: .loading
        )
        let view = DrivingLicenceView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_drivingLicenceSummaryView_light_rendersCorrectly() {
        let viewModel = MockDrivingLicenceViewModel(
            viewState: .loaded(
                licence: DrivingLicenceSummaryViewModel(
                    drivingLicence: mockDrivingLicence,
                    statusBuilder: MockLicenceStatusViewModelBuilder(),
                    openURLAction: { _,_ in },
                    menuSelectionAction: { _ in },
                    analyticsService: MockAnalyticsService()
                )
            )
        )
        let view = DrivingLicenceView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_drivingLicenceSummaryView_dark_rendersCorrectly() {
        let viewModel = MockDrivingLicenceViewModel(
            viewState: .loaded(
                licence: DrivingLicenceSummaryViewModel(
                    drivingLicence: mockDrivingLicence,
                    statusBuilder: MockLicenceStatusViewModelBuilder(),
                    openURLAction: { _,_  in },
                    menuSelectionAction: { _ in },
                    analyticsService: MockAnalyticsService()
                )
            )
        )
        let view = DrivingLicenceView(viewModel: viewModel)
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

        let viewModel = MockDrivingLicenceViewModel(
            viewState: .error(errorViewModel)
        )
        let view = DrivingLicenceView(viewModel: viewModel)
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

        let viewModel = MockDrivingLicenceViewModel(
            viewState: .error(errorViewModel)
        )
        let view = DrivingLicenceView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
    private var mockDrivingLicence: DrivingLicence {
        DrivingLicence(
            licenceType: "Full", licenceNumber: "ABC1234567DE",
            driverTitle: "Mr",
            driverFirstNames: "Joe",
            driverLastName: "Bloggs",
            driverFullAddress: "",
            tokenValidToDate: Date(), licenceStatus: .valid
        )
    }
}
