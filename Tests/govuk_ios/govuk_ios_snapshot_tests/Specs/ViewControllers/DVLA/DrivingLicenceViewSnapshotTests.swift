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
                    driverSummary: .arrange,
                    statusBuilder: MockLicenceStatusViewModelBuilder(),
                    openURLAction: { _ in },
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
                    driverSummary: .arrange,
                    statusBuilder: MockLicenceStatusViewModelBuilder(),
                    openURLAction: { _ in },
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
        let errorViewModel = AppErrorViewModel(
            title: "Test error",
            body: "Something went wrong.",
            buttonTitle: "Try again"
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
        let errorViewModel = AppErrorViewModel(
            title: "Test error",
            body: "Something went wrong.",
            buttonTitle: "Try again"
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
}
