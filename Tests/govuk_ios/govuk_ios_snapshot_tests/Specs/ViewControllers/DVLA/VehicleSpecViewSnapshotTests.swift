import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class VehicleSpecViewSnapshotTests: SnapshotTestCase {
    func test_shortStrings_light_rendersCorrectly() {
        let viewModel = VehicleSpecViewModel(
            colour: "Yellow",
            fuelTypeIcon: "fuelpump.fill",
            fuelTypeName: "Petrol",
            year: "2000"
        )
        let view = VehicleSpecView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_shortString_dark_rendersCorrectly() {
        let viewModel = VehicleSpecViewModel(
            colour: "Yellow",
            fuelTypeIcon: "fuelpump.fill",
            fuelTypeName: "Petrol",
            year: "2000"
        )
        let view = VehicleSpecView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_longStrings_light_rendersCorrectly() {
        let viewModel = VehicleSpecViewModel(
            colour: "Very long colour",
            fuelTypeIcon: "fuelpump.fill",
            fuelTypeName: "Very very long fuel type name",
            year: "2000"
        )
        let view = VehicleSpecView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_longStrings_dark_rendersCorrectly() {
        let viewModel = VehicleSpecViewModel(
            colour: "Very long colour",
            fuelTypeIcon: "fuelpump.fill",
            fuelTypeName: "Very very long fuel type name",
            year: "2000"
        )
        let view = VehicleSpecView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
}
