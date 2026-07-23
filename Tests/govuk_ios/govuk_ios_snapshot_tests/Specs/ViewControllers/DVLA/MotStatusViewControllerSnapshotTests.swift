import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class MotStatusViewControllerSnapshotTests: SnapshotTestCase {
    func test_statusWithButtonAndFooter_light_rendersCorrectly() {
        let viewModel = ValidityStatusViewModel(
            title: nil,
            formattedStatus: "Formatted status",
            iconName: "exclamationmark.triangle.fill",
            iconTintColour: nil,
            footer: "Footer title",
            buttonTitle: "Mot",
            buttonAction: { }
        )
        let view = MotValidityStatusView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_statusWithButtonAndFooter_dark_rendersCorrectly() {
        let viewModel = ValidityStatusViewModel(
            title: nil,
            formattedStatus: "Formatted status",
            iconName: "exclamationmark.triangle.fill",
            iconTintColour: nil,
            footer: "Footer title",
            buttonTitle: "Mot",
            buttonAction: { }
        )
        let view = MotValidityStatusView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_statusWithoutButtonAndFooter_light_rendersCorrectly() {
        let viewModel = ValidityStatusViewModel(
            title: nil,
            formattedStatus: "Formatted status",
            iconName: "exclamationmark.triangle.fill",
            iconTintColour: nil,
            footer: "Footer title",
            buttonTitle: "Mot",
            buttonAction: { }
        )
        let view = MotValidityStatusView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_statusWithoutButtonAndFooter_dark_rendersCorrectly() {
        let viewModel = ValidityStatusViewModel(
            title: nil,
            formattedStatus: "Formatted status",
            iconName: "exclamationmark.triangle.fill",
            iconTintColour: nil,
            footer: "Footer title",
            buttonTitle: "Mot",
            buttonAction: { }
        )
        let view = MotValidityStatusView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_statusWithProgressBar_light_rendersCorrectly() {
        let viewModel = ValidityStatusViewModel(
            formattedStatus: "Expiring 22 June 2026",
            progressViewModel: ExpiryProgressViewModel(progress: 0.5, daysLeft: 10),
            footer: "footer text.",
            buttonTitle: "Renew mot",
            buttonAction: {}
        )
        let view = MotValidityStatusView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_statusWithProgressBar_dark_rendersCorrectly() {
        let viewModel = ValidityStatusViewModel(
            formattedStatus: "Expiring 22 June 2026",
            progressViewModel: ExpiryProgressViewModel(progress: 0.5, daysLeft: 10),
            footer: "footer text.",
            buttonTitle: "Renew mot",
            buttonAction: {}
        )
        let view = MotValidityStatusView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
}

