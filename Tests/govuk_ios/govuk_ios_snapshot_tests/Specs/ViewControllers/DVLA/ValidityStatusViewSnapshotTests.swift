import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class ValidityStatusViewSnapshotTests: SnapshotTestCase {
    func test_statusWithButtonAndFooter_light_rendersCorrectly() {
        let viewModel = ValidityStatusViewModel(
            title: nil,
            status: "Expired 22 June 2026",
            iconName: "exclamationmark.triangle.fill",
            iconTintColour: nil,
            footer: "Your licence status may not update immediately after renewing.",
            buttonTitle: "Renew licence",
            buttonAction: { }
        )
        let view = ValidityStatusView(viewModel: viewModel)
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
            status: "Expired 22 June 2026",
            iconName: "exclamationmark.triangle.fill",
            iconTintColour: nil,
            footer: "Your licence status may not update immediately after renewing.",
            buttonTitle: "Renew licence",
            buttonAction: { }
        )
        let view = ValidityStatusView(viewModel: viewModel)
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
            status: "Valid until 22 June 2026",
            iconName: "checkmark.circle.fill",
            iconTintColour: .govUK.fills.surfaceButtonPrimary,
            footer: nil,
            buttonTitle: nil,
            buttonAction: nil
        )
        let view = ValidityStatusView(viewModel: viewModel)
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
            status: "Valid until 22 June 2026",
            iconName: "checkmark.circle.fill",
            iconTintColour: .govUK.fills.surfaceButtonPrimary,
            footer: nil,
            buttonTitle: nil,
            buttonAction: nil
        )
        let view = ValidityStatusView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
}
