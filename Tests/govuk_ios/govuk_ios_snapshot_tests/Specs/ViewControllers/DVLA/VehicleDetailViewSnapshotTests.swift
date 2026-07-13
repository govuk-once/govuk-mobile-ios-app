import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class VehicleDetailViewSnapshotTests: SnapshotTestCase {
    func test_fullyPopulatedVehicle_light_rendersCorrectly() async {
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange(
            taxedUntil: .arrange("12/12/2030"),
            motStatus: "Valid",
            motExpiryDate: .arrange("12/12/2030")
        )
        let mockVehicleDetails = CustomerVehicleDetails.arrange(
            customerVehicleDetails: mockVehicle
        )
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .success(mockVehicleDetails)
        let viewModel = VehicleDetailViewModel(
            vehicleId: 123,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService,
            configService: MockAppConfigService(),
            openURLAction: { _ in }
        )
        await viewModel.viewDidAppear()
        let view = VehicleDetailView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_fullyPopulatedVehicle_dark_rendersCorrectly() async {
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange(
            taxedUntil: .arrange("12/12/2030"),
            motStatus: "Valid",
            motExpiryDate: .arrange("12/12/2030")
        )
        let mockVehicleDetails = CustomerVehicleDetails.arrange(
            customerVehicleDetails: mockVehicle
        )
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .success(mockVehicleDetails)
        let viewModel = VehicleDetailViewModel(
            vehicleId: 123,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService,
            configService: MockAppConfigService(),
            openURLAction: { _ in }
        )
        await viewModel.viewDidAppear()
        let view = VehicleDetailView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_missingVehicleProperties_light_rendersCorrectly() async {
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange(
            model: nil,
            taxStatus: nil,
            taxedUntil: nil,
            motExpiryDate: nil,
            secondaryColour: nil,
            exhaustEmissionsCo2: nil,
            engineCapacity: nil,
            keeperTitle: nil,
            keeperFirstNames: nil,
            keeperLastName: nil
        )
        let mockVehicleDetails = CustomerVehicleDetails.arrange(
            customerVehicleDetails: mockVehicle
        )
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .success(mockVehicleDetails)
        let viewModel = VehicleDetailViewModel(
            vehicleId: 123,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService,
            configService: MockAppConfigService(),
            openURLAction: { _ in }
        )
        await viewModel.viewDidAppear()
        let view = VehicleDetailView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_missingVehicleProperties_dark_rendersCorrectly() async {
        let mockVehicle = CustomerVehicleDetails.Vehicle.arrange(
            model: nil,
            taxStatus: nil,
            taxedUntil: nil,
            motExpiryDate: nil,
            secondaryColour: nil,
            exhaustEmissionsCo2: nil,
            engineCapacity: nil,
            keeperTitle: nil,
            keeperFirstNames: nil,
            keeperLastName: nil
        )
        let mockVehicleDetails = CustomerVehicleDetails.arrange(
            customerVehicleDetails: mockVehicle
        )
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .success(mockVehicleDetails)
        let viewModel = VehicleDetailViewModel(
            vehicleId: 123,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService,
            configService: MockAppConfigService(),
            openURLAction: { _ in }
        )
        await viewModel.viewDidAppear()
        let view = VehicleDetailView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_apiError_light_rendersCorrectly() async {
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .failure(.apiUnavailable)
        let viewModel = VehicleDetailViewModel(
            vehicleId: 123,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService,
            configService: MockAppConfigService(),
            openURLAction: { _ in }
        )
        await viewModel.viewDidAppear()
        let view = VehicleDetailView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_apiError_dark_rendersCorrectly() async {
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedCustomerVehicleDetailsResult = .failure(.apiUnavailable)
        let viewModel = VehicleDetailViewModel(
            vehicleId: 123,
            analyticsService: MockAnalyticsService(),
            dvlaService: mockDVLAService,
            configService: MockAppConfigService(),
            openURLAction: { _ in }
        )
        await viewModel.viewDidAppear()
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
