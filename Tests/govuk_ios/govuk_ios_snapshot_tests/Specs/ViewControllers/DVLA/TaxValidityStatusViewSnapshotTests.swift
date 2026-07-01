import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class TaxValidityStatusViewSnapshotTests: SnapshotTestCase {
    func test_statusWithButtonAndFooter_light_rendersCorrectly() {
        let viewModel = ValidityStatusViewModel(
            title: "Tax",
            formattedStatus: "Expired 22 June 2026",
            status: TaxStatus.untaxed,
            iconName: "exclamationmark.triangle.fill",
            iconTintColour: nil,
            footer: "Your tax status may not update immediately after renewing.",
            buttonTitle: "Renew tax",
            buttonAction: { }
        )
        let view = TaxValidityStatusView(viewModel: viewModel)
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
            title: "Tax",
            formattedStatus: "Expired 22 June 2026",
            status: TaxStatus.untaxed,
            iconName: "exclamationmark.triangle.fill",
            iconTintColour: nil,
            footer: "Your tax status may not update immediately after renewing.",
            buttonTitle: "Renew tax",
            buttonAction: { }
        )
        let view = TaxValidityStatusView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_sornStatus_light_rendersCorrectly() {
        let viewModel = ValidityStatusViewModel(
            title: nil,
            formattedStatus: "SORN",
            status: TaxStatus.sorn,
            iconName: "exclamationmark.triangle.fill",
            iconTintColour: nil,
            footer: "From 2nd June 2016"
        )
        let view = TaxValidityStatusView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_sornStatus_dark_rendersCorrectly() {
        let viewModel = ValidityStatusViewModel(
            title: nil,
            formattedStatus: "SORN",
            status: TaxStatus.sorn,
            iconName: "exclamationmark.triangle.fill",
            iconTintColour: nil,
            footer: "From 2nd June 2016"
        )
        let view = TaxValidityStatusView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
}
