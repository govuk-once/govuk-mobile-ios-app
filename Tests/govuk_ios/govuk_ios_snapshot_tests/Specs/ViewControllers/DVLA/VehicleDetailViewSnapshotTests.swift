import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class VehicleDetailViewSnapshotTests: SnapshotTestCase {
    func test_fullyPopulatedVehicle_light_rendersCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            taxedUntil: .arrange("12/12/2030"),
            motStatus: "Valid",
            motExpiryDate: .arrange("12/12/2030")
        )
        let viewModel = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: mockVehicle,
            openURLAction: { _ in }
        )
        let view = VehicleDetailView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_fullyPopulatedVehicle_dark_rendersCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            taxedUntil: .arrange("12/12/2030"),
            motStatus: "Valid",
            motExpiryDate: .arrange("12/12/2030")
        )
        let viewModel = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: mockVehicle,
            openURLAction: { _ in }
        )
        let view = VehicleDetailView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_missingVehicleProperties_light_rendersCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            model: nil,
            taxStatus: nil,
            taxedUntil: nil,
            motExpiryDate: nil,
            secondaryColour: nil,
            exhaustEmissions: nil,
            engineCapacity: nil,
            keeper: nil
        )
        let viewModel = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: mockVehicle,
            openURLAction: { _ in }
        )
        let view = VehicleDetailView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_missingVehicleProperties_dark_rendersCorrectly() {
        let mockVehicle = CustomerSummary.Vehicle.arrange(
            model: nil,
            taxStatus: nil,
            taxedUntil: nil,
            motExpiryDate: nil,
            secondaryColour: nil,
            exhaustEmissions: nil,
            engineCapacity: nil,
            keeper: nil
        )
        let viewModel = VehicleDetailViewModel(
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            vehicle: mockVehicle,
            openURLAction: { _ in }
        )
        let view = VehicleDetailView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
}
