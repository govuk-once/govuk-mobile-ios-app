import Testing
import Foundation
@testable import govuk_ios

@MainActor
@Suite
struct RegistrationNumberFormViewModelTests {

    // Helper to mirror the submitAction closure from ViewControllerBuilder
    private func makeSubmitAction(
        dvlaService: DVLAServiceInterface
    ) -> VehicleLookup {
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

    // MARK: - Submission Tests

    @Test
    func performSubmit_handlesSuccess() async {
        let expectedVehicle = VehicleEnquiryResponse.Vehicle.arrange
        let mockService = MockDVLAService()
        mockService._stubbedFetchVehicleResult = .success(.init(vehicle: expectedVehicle))

        var receivedVehicle: VehicleEnquiryResponse.Vehicle?
        let viewModel = makeViewModel(
            initialPlate: "AB12 CDE",
            lookupService: makeSubmitAction(dvlaService: mockService),
            onSuccess: { vehicle in
                receivedVehicle = vehicle
            }
        )

        await viewModel.performSubmit()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.isSubmitted == true)
        #expect(viewModel.error == nil)
        #expect(viewModel.fetchedVehicle?.vehicleId == expectedVehicle.vehicleId)
        #expect(receivedVehicle?.vehicleId == expectedVehicle.vehicleId)
    }

    @Test
    func performSubmit_handlesNotFoundError() async {
        let mockService = MockDVLAService()
        mockService._stubbedFetchVehicleResult = .failure(.notFound)

        var successCallbackCalled = false
        let viewModel = makeViewModel(
            initialPlate: "AB12 CDE",
            lookupService: makeSubmitAction(dvlaService: mockService),
            onSuccess: { _ in
                successCallbackCalled = true
            }
        )

        await viewModel.performSubmit()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.isSubmitted == false)
        #expect(viewModel.fetchedVehicle == nil)
        #expect(viewModel.error == .notFound)
        #expect(successCallbackCalled == false)
    }

    @Test
    func performSubmit_whenPlateIsInvalid_doesNotTriggerLookup() async {
        let mockService = MockDVLAService()
        let viewModel = makeViewModel(
            initialPlate: "A",
            lookupService: makeSubmitAction(dvlaService: mockService)
        )

        await viewModel.performSubmit()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.isSubmitted == false)
        #expect(viewModel.fetchedVehicle == nil)
    }

    @Test
    func cancel_triggersOnCancelCallback() {
        var cancelCalled = false
        let viewModel = makeViewModel(
            onCancel: {
                cancelCalled = true
            }
        )

        viewModel.cancel()

        #expect(cancelCalled == true)
    }

    // MARK: - Error & Sanitization Tests

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
        lookupService: VehicleLookup? = nil,
        onSuccess: @escaping (VehicleEnquiryResponse.Vehicle) -> Void = { _ in },
        onCancel: @escaping () -> Void = {}
    ) -> RegistrationNumberFormViewModel {
        let defaultLookupService: VehicleLookup = { _ in
            .success(VehicleEnquiryResponse.Vehicle.arrange)
        }
        let viewModel = RegistrationNumberFormViewModel(
            lookupService: lookupService ?? defaultLookupService,
            onSuccess: onSuccess,
            onCancel: onCancel
        )
        viewModel.numberPlate = initialPlate
        viewModel.clearsErrorOnAnyEdit = clearsErrorOnAnyEdit
        return viewModel
    }

    private func makeViewModelWithError(
        initialPlate: String = "AB12",
        clearsErrorOnAnyEdit: Bool = true
    ) async -> RegistrationNumberFormViewModel {
        let failingLookupService: VehicleLookup = { _ in
            .failure(.serviceUnavailable)
        }
        let viewModel = makeViewModel(
            initialPlate: initialPlate,
            clearsErrorOnAnyEdit: clearsErrorOnAnyEdit,
            lookupService: failingLookupService
        )
        await viewModel.performSubmit()
        return viewModel
    }
}
