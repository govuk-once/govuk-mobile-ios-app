import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class VehicleCheckResultViewSnapshotTests: SnapshotTestCase {

    private var mockVehicle: VehicleEnquiryResponse.Vehicle {
        .arrange(
            vehicleId: 100830769,
            registrationNumber: "DF04 FSY",
            taxStatus: .untaxed,
            taxedUntil: nil,
            motStatus: "Not valid",
            motExpiryDate: .arrange("10/05/2026"),
            make: "FORD",
            dateOfFirstRegistration: .arrange("01/05/2004"),
            engineCapacity: 1242,
            exhaustEmissionsCo2: 147,
            fuelType: .petrol,
            colour: "BLACK",
            secondaryColour: nil
        )
    }

    func test_light_rendersCorrectly() {
        let viewModel = VehicleCheckResultViewModel(
            vehicle: mockVehicle,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            actions: .empty
        )
        let view = VehicleCheckResultView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_dark_rendersCorrectly() {
        let viewModel = VehicleCheckResultViewModel(
            vehicle: mockVehicle,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            actions: .empty
        )
        let view = VehicleCheckResultView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
}

extension VehicleCheckResultActions {
    static var empty: VehicleCheckResultActions {
        .init(
            openURLAction: { _ in },
            searchAction: {},
            dismissAction: {}
        )
    }
}
