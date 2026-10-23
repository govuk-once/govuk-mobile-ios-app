import Testing
import Foundation
@testable import govuk_ios

@MainActor
@Suite
struct RegistrationNumberFormViewModelTests {

    // Helper to mirror the submitAction closure from ViewControllerBuilder
    private func makeSubmitAction(
        dvlaService: DVLAServiceInterface
    ) -> RegistrationNumberSubmitAction {
        return { plate in
            let result = await dvlaService.fetchVehicle(registration: plate)
            switch result {
            case .success(let response):
                return .success(response.vehicle)
            case .failure(let error):
                switch error {
                case .notFound:
                    return .failure(.notFound)
                default:
                    return .failure(.serviceUnavailable)
                }
            }
        }
    }

    @Test
    func submitAction_handlesSuccess() async {
        let expectedVehicle = VehicleEnquiryResponse.Vehicle.arrange
        let mockService = MockDVLAService()
        mockService._stubbedFetchVehicleResult = .success(.init(vehicle: expectedVehicle))

        let viewModel = RegistrationNumberFormViewModel(
            submitAction: makeSubmitAction(dvlaService: mockService)
        )

        let submitResult = await viewModel.submitAction("AB12 CDE")

        switch submitResult {
        case .success(let vehicle):
            #expect(vehicle.vehicleId == expectedVehicle.vehicleId)
        default:
            Issue.record("Expected success result with vehicle, but got \(String(describing: submitResult))")
        }
    }

    @Test
    func submitAction_handlesNotFoundError() async {
        let mockService = MockDVLAService()
        mockService._stubbedFetchVehicleResult = .failure(.notFound)

        let viewModel = RegistrationNumberFormViewModel(
            submitAction: makeSubmitAction(dvlaService: mockService)
        )

        let submitResult = await viewModel.submitAction("AB12 CDE")

        switch submitResult {
        case .failure(let error):
            #expect(error == .notFound)
        default:
            Issue.record("Expected notFound failure result, but got \(String(describing: submitResult))")
        }
    }
}
