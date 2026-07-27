import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class MotStatusViewControllerSnapshotTests: SnapshotTestCase {
    func test_noDetailsHeldByDVLA_light_rendersCorrectly() {
        let status: MOTValidityStatus  = .noDetailsHeldByDVLA
        let viewModel = ValidityStatusViewModel(
            title: "MOT",
            formattedStatus: "",
            status: status,
            iconName: nil,
            iconTintColour: nil,
            footer:  nil,
            buttonTitle: "Check if it needs Mot",
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

    func test_noDetailsHeldByDVLA_dark_rendersCorrectly() {
        let status: MOTValidityStatus  = .noDetailsHeldByDVLA
        let viewModel = ValidityStatusViewModel(
            title: "MOT",
            formattedStatus: "",
            status: status,
            iconName: nil,
            iconTintColour: nil,
            footer:  nil,
            buttonTitle: "Check if it needs Mot",
            buttonAction: { }
        )
        let view = MotValidityStatusView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
    func test_noResultsReturned_light_rendersCorrectly() {
        let status: MOTValidityStatus = .noResultsReturned
        let viewModel = ValidityStatusViewModel(
            title: "MOT",
            formattedStatus: "",
            status: status,
            iconName: nil,
            iconTintColour: nil,
            footer:  nil,
            buttonTitle: "Check if it needs Mot",
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

    func test_noResultsReturned_dark_rendersCorrectly() {
        let status: MOTValidityStatus = .noResultsReturned
        let viewModel = ValidityStatusViewModel(
            title: "MOT",
            formattedStatus: "",
            status: status,
            iconName: nil,
            iconTintColour: nil,
            footer:  nil,
            buttonTitle: "Check if it needs Mot",
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
}

