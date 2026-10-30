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

    // MARK: - Validation Tests

    @Test(arguments: [
        ("", false),
        ("A", false),
        ("!", false),
        ("AB", true),
        ("A 1", true),
        ("AB12 CDE", true),
        ("AB12 CDEF", false) // 8 alphanumeric characters
    ])
    func isValidPlate_evaluatesCorrectly(input: String, expected: Bool) {
        let viewModel = makeViewModel(initialPlate: input)
        #expect(viewModel.isValidPlate == expected)
    }

    @Test
    func isValidPlate_respectsCustomMaxCharacters() {
        let viewModel = RegistrationNumberFormViewModel(
            maxCharacters: 5,
            lookupService: { _ in .success(.arrange) },
            onSuccess: { _ in },
            onCancel: {}
        )
        viewModel.numberPlate = "AB12 C"
        #expect(viewModel.isValidPlate == true)

        viewModel.numberPlate = "AB12 CD"
        #expect(viewModel.isValidPlate == false)
    }

    // MARK: - Error Clearing (didSet) Tests

    @Test
    func numberPlate_didSet_doesNothingWhenNoError() {
        let viewModel = makeViewModel(initialPlate: "AB12")
        #expect(viewModel.error == nil)

        viewModel.numberPlate = "AB12 C"
        #expect(viewModel.error == nil)
    }

    @Test
    func numberPlate_didSet_clearsErrorOnAnyEditWhenFlagIsTrue() async {
        let viewModel = await makeViewModelWithError(initialPlate: "AB12", clearsErrorOnAnyEdit: true)
        #expect(viewModel.error != nil)

        viewModel.numberPlate = "AB12 C"
        #expect(viewModel.error == nil)
    }

    @Test
    func numberPlate_didSet_clearsErrorOnlyOnDeletionWhenFlagIsFalse() async {
        let viewModel = await makeViewModelWithError(initialPlate: "AB12", clearsErrorOnAnyEdit: false)
        #expect(viewModel.error != nil)

        // Adding a character should NOT clear the error
        viewModel.numberPlate = "AB12 C"
        #expect(viewModel.error != nil)

        // Deleting characters should clear the error
        viewModel.numberPlate = "AB1"
        #expect(viewModel.error == nil)
    }

    @Test
    func numberPlate_didSet_ignoresSanitizerBounceBack() async {
        let viewModel = await makeViewModelWithError(initialPlate: "AB12 CDE", clearsErrorOnAnyEdit: true)
        #expect(viewModel.error != nil)

        // Formatter sanitizes out excess characters beyond maxCharacters (7)
        // Both sanitize to "AB12 CDE", so oldClean == newClean
        viewModel.numberPlate = "AB12 CDEX"
        #expect(viewModel.error != nil)
    }

    // MARK: - Error Message Tests

    @Test
    func errorMessage_returnsNilWhenNoError() {
        let viewModel = makeViewModel()
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func errorMessage_returnsNotFoundStringForNotFoundError() async {
        let viewModel = makeViewModel(
            lookupService: { _ in .failure(.notFound()) }
        )
        await viewModel.performSubmit()

        #expect(viewModel.errorMessage == String(localized: .DVLA.registrationLookupNotFound))
    }

    @Test
    func errorMessage_returnsServiceUnavailableStringForOtherErrors() async {
        let viewModel = makeViewModel(
            lookupService: { _ in .failure(.serviceUnavailable(statusCode: nil)) }
        )
        await viewModel.performSubmit()

        #expect(viewModel.errorMessage == String(localized: .DVLA.registrationLookupServiceUnavailable))
    }

    // MARK: - Action and Execution Tests

    @Test
    func performSubmit_trimsWhitespaceBeforeQueryingService() async {
        var queriedPlate: String?

        let viewModel = makeViewModel(
            initialPlate: "  AB12 CDE  ",
            lookupService: { plate in
                queriedPlate = plate
                return .success(.arrange)
            }
        )

        await viewModel.performSubmit()
        #expect(queriedPlate == "AB12 CDE")
    }

    @Test
    func cancel_invokesOnCancelCallback() {
        var cancelCalled = false
        let viewModel = makeViewModel(onCancel: {
            cancelCalled = true
        })

        viewModel.cancel()
        #expect(cancelCalled == true)
    }

    @Test
    func submit_spawnsTaskAndExecutesSubmission() async throws {
        var receivedVehicle: VehicleEnquiryResponse.Vehicle?
        let expectedVehicle = VehicleEnquiryResponse.Vehicle.arrange

        let viewModel = makeViewModel(
            initialPlate: "AB12 CDE",
            lookupService: { _ in .success(expectedVehicle) },
            onSuccess: { receivedVehicle = $0 }
        )

        viewModel.submit()

        // Allow the spawned Task to complete
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.isSubmitted == true)
        #expect(receivedVehicle?.vehicleId == expectedVehicle.vehicleId)
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
