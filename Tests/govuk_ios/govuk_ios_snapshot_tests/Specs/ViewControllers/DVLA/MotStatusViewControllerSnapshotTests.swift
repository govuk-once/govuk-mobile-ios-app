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
            status: status,
            statusInformation: StatusInformation(String(localized: .DVLA.motCheckIfItNeedsAnMOT),
                                                 linkAction: {}),
            iconName: nil,
            iconTintColour: nil,
            footer:  nil,
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

    func test_noDetailsHeldByDVLA_dark_rendersCorrectly() {
        let status: MOTValidityStatus  = .noDetailsHeldByDVLA
        let viewModel = ValidityStatusViewModel(
            title: "MOT",
            status: status,
            statusInformation: StatusInformation(String(localized: .DVLA.motCheckIfItNeedsAnMOT),
                                                linkAction: {}),
            iconName: nil,
            iconTintColour: nil,
            footer:  nil,
        )
        let view = ValidityStatusView(viewModel: viewModel)
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
            status: status,
            statusInformation: StatusInformation(String(localized: .DVLA.motCheckIfItNeedsAnMOT),
                                                 linkAction: {}),
            iconName: nil,
            iconTintColour: nil,
            footer:  nil,
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

    func test_noResultsReturned_dark_rendersCorrectly() {
        let status: MOTValidityStatus = .noResultsReturned
        let viewModel = ValidityStatusViewModel(
            title: "MOT",
            status: status,
            statusInformation: StatusInformation(String(localized: .DVLA.motCheckIfItNeedsAnMOT),
                                                linkAction: {}),
            iconName: nil,
            iconTintColour: nil,
            footer:  nil,
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

