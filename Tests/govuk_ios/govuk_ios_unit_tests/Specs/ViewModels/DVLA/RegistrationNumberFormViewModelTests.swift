import Testing
import Foundation
@testable import govuk_ios

@MainActor
@Suite
struct RegistrationNumberFormViewModelTests {
    // MARK: - Submission Tests

    @Test
    func performSubmit_handlesSuccess() async {
        let expectedVehicle = VehicleEnquiryResponse.Vehicle.arrange
        var receivedVehicle: VehicleEnquiryResponse.Vehicle?

        let viewModel = makeViewModel(
            initialPlate: "AB12 CDE",
            lookupService: { _ in .success(expectedVehicle) },
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
        var successCallbackCalled = false

        let viewModel = makeViewModel(
            initialPlate: "AB12 CDE",
            lookupService: { _ in .failure(.notFound()) },
            onSuccess: { _ in
                successCallbackCalled = true
            }
        )

        await viewModel.performSubmit()
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isSubmitted == false)
        #expect(viewModel.fetchedVehicle == nil)
        #expect(viewModel.error == .notFound())
        #expect(successCallbackCalled == false)
    }

    @Test
    func performSubmit_whenPlateIsInvalid_doesNotTriggerLookup() async {
        var lookupCalled = false

        let viewModel = makeViewModel(
            initialPlate: "A",
            lookupService: { _ in
                lookupCalled = true
                return .failure(.notFound())
            }
        )

        await viewModel.performSubmit()
        #expect(lookupCalled == false)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isSubmitted == false)
        #expect(viewModel.fetchedVehicle == nil)
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
            .failure(.serviceUnavailable(statusCode: nil))
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
