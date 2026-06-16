import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class VehicleSummaryViewSnapshotTests: SnapshotTestCase {
    func test_vehicleSummaryView_validTaxAndMot_light_rendersCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            taxedUntil: Date(timeIntervalSince1970: 1779975444),
            motExpiryDate: Date(timeIntervalSince1970: 1779975444)
        )
        let viewModel = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailTappedAction: {}
        )
        let view = VehicleSummaryView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_vehicleSummaryView_validTaxAndMot_dark_rendersCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            taxedUntil: Date(timeIntervalSince1970: 1779975444),
            motExpiryDate: Date(timeIntervalSince1970: 1779975444)
        )
        let viewModel = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailTappedAction: {}
        )
        let view = VehicleSummaryView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_vehicleSummaryView_unknownTaxAndMot_light_rendersCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            taxedUntil: nil,
            motExpiryDate: nil
        )
        let viewModel = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailTappedAction: {}
        )
        let view = VehicleSummaryView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_vehicleSummaryView_unknownTaxAndMot_dark_rendersCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            taxedUntil: nil,
            motExpiryDate: nil
        )
        let viewModel = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailTappedAction: {}
        )
        let view = VehicleSummaryView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
}
