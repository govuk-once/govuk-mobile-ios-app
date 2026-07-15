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
                    drivingLicence: .arrange,
                    statusBuilder: MockLicenceStatusViewModelBuilder(),
                    openURLAction: { _, _ in },
                    menuSelectionAction: { _ in },
                    copyToClipboardAction: { _ in },
                    analyticsService: MockAnalyticsService()
                ),
                drivingRecord: DrivingRecordViewModel(
                    dvlaURLs: nil,
                    openURLAction: { _, _ in }
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
                    drivingLicence: .arrange,
                    statusBuilder: MockLicenceStatusViewModelBuilder(),
                    openURLAction: { _, _ in },
                    menuSelectionAction: { _ in },
                    copyToClipboardAction: { _ in },
                    analyticsService: MockAnalyticsService()
                ),
                drivingRecord: DrivingRecordViewModel(
                    dvlaURLs: nil,
                    openURLAction: { _, _ in }
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

    func test_licenceNoticeView_light_rendersCorrectly() {
        let noticeViewModel = DrivingLicenceNoticeViewModel(
            title: String(localized: .DVLA.licenceNotAvailableTitle),
            body: String(localized: .DVLA.licenceNotAvailableBody),
            buttonTitle: String(localized: .DVLA.licenceNotAvailableButtonTitle),
            action: {}
        )
        let viewModel = MockDrivingLicenceViewModel(
            viewState: .notice(noticeViewModel)
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

    func test_licenceNoticeView_dark_rendersCorrectly() {
        let noticeViewModel = DrivingLicenceNoticeViewModel(
            title: String(localized: .DVLA.licenceNotAvailableTitle),
            body: String(localized: .DVLA.licenceNotAvailableBody),
            buttonTitle: String(localized: .DVLA.licenceNotAvailableButtonTitle),
            action: {}
        )
        let viewModel = MockDrivingLicenceViewModel(
            viewState: .notice(noticeViewModel)
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
