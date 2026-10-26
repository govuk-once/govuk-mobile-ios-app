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

    @Test func test_numberPlate_sanitizerBounceBack_retainsError() async {
        let viewModel = await makeViewModelWithError(
            initialPlate: "AB12 CDE",
            clearsErrorOnAnyEdit: true
        )

        viewModel.numberPlate = "AB12 CDEX"
        #expect(viewModel.error != nil)
    }

    @Test func test_numberPlate_cleanEdit_clearsError_whenClearsErrorOnAnyEditIsTrue() async {
        let viewModel = await makeViewModelWithError(
            initialPlate: "AB12",
            clearsErrorOnAnyEdit: true
        )

        viewModel.numberPlate = "AB12C"
        #expect(viewModel.error == nil)
    }

    @Test func test_numberPlate_deleteCharacter_clearsError_whenClearsErrorOnAnyEditIsFalse() async {
        let viewModel = await makeViewModelWithError(
            initialPlate: "AB12",
            clearsErrorOnAnyEdit: false
        )

        viewModel.numberPlate = "AB1"
        #expect(viewModel.error == nil)
    }

    @Test func test_numberPlate_addCharacter_retainsError_whenClearsErrorOnAnyEditIsFalse() async {
        let viewModel = await makeViewModelWithError(
            initialPlate: "AB12",
            clearsErrorOnAnyEdit: false
        )

        viewModel.numberPlate = "AB12C"
        #expect(viewModel.error != nil)
    }

    @Test func test_numberPlate_editWithNilError_remainsNil() {
        let viewModel = makeViewModel(
            initialPlate: "AB12",
            clearsErrorOnAnyEdit: true
        )

        viewModel.numberPlate = "AB12C"
        #expect(viewModel.error == nil)
    }
}

// MARK: - Factory Helpers
extension RegistrationNumberFormViewModelTests {

    private func makeViewModel(
        initialPlate: String = "AB12",
        clearsErrorOnAnyEdit: Bool = true,
        submitAction: RegistrationNumberSubmitAction? = nil
    ) -> RegistrationNumberFormViewModel {
        let defaultSubmitAction: RegistrationNumberSubmitAction = { _ in
            .success(VehicleEnquiryResponse.Vehicle.arrange)
        }
        let viewModel = RegistrationNumberFormViewModel(
            submitAction: submitAction ?? defaultSubmitAction
        )
        viewModel.numberPlate = initialPlate
        viewModel.clearsErrorOnAnyEdit = clearsErrorOnAnyEdit
        return viewModel
    }

    private func makeViewModelWithError(
        initialPlate: String = "AB12",
        clearsErrorOnAnyEdit: Bool = true
    ) async -> RegistrationNumberFormViewModel {
        let failingSubmitAction: RegistrationNumberSubmitAction = { _ in
                .failure(.serviceUnavailable)
        }
        let viewModel = makeViewModel(
            initialPlate: initialPlate,
            clearsErrorOnAnyEdit: clearsErrorOnAnyEdit,
            submitAction: failingSubmitAction
        )
        await viewModel.submit()
        return viewModel
    }
}
