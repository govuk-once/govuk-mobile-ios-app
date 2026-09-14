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
            statusInformation: .init("Expired 22 June 2026"),
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
            statusInformation: .init("Expired 22 June 2026"),
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
            status: TaxValidityStatus.sorn,
            statusInformation: .init("SORN"),
            iconName: "parkingsign.brakesignal",
            iconTintColour: nil,
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

    func test_futureSornStatus_dark_rendersCorrectly() {
        let viewModel = ValidityStatusViewModel(
            title: nil,
            status: TaxValidityStatus.futureSorn,
            statusInformation: .init("SORN"),
            iconName: "parkingsign.brakesignal",
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
    
    
    fileprivate func viewModelForUnknownStatus() -> ValidityStatusViewModel {
        ValidityStatusViewModel(
            title: String(localized: .DVLA.taxStatusTitle),
            status: TaxValidityStatus.unknown,
            statusInformation: .init(String(localized: .DVLA.notFoundContactDVLA),
                                     linkAction: {}),
        )

    }
    
    func test_unknownStatus_light_rendersCorrectly() {
        let viewModel = viewModelForUnknownStatus()
        let view = TaxValidityStatusView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_unknownStatus_dark_rendersCorrectly() {
        let viewModel = viewModelForUnknownStatus()
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
