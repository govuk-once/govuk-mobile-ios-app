import SwiftUI
import Combine

typealias VehicleLookup =
(String) async -> Result<
    VehicleEnquiryResponse.Vehicle,
        DVLADomainError
>

/// Owns registration number input state, validation, and submission.
@MainActor
final class RegistrationNumberFormViewModel: ObservableObject {
    private var submitTask: Task<Void, Never>?

    @Published var numberPlate: String = "" {
        // Clears the error when the user edits the plate, so they can retry after a failed submission.
        // Compares sanitized forms to ignore the intermediate value from the sanitizer bounce-back
        // (e.g. typing an 8th char briefly sets "AB12 CDEX" before sanitizing back to "AB12 CDE").
        didSet {
            guard error != nil else { return }
            let oldClean = RegistrationNumberFormatter.sanitize(
                oldValue,
                maxAlphanumerics: maxCharacters
            )
            let newClean = RegistrationNumberFormatter.sanitize(
                numberPlate,
                maxAlphanumerics: maxCharacters)
            guard newClean != oldClean else { return }

            if clearsErrorOnAnyEdit {
                error = nil
            } else if alphanumericCount(newClean) < alphanumericCount(oldClean) {
                error = nil
            }
        }
    }
    @Published private(set) var isLoading = false
    @Published private(set) var isSubmitted = false
    let loadingLabel = String(localized: .DVLA.gettingVehicleDetails)
    @Published private(set) var error: DVLADomainError?

    var errorMessage: String? {
        guard let error else { return nil }
        switch error {
        case .notFound:
            return String(localized: .DVLA.registrationLookupNotFound)
        case .networkUnavailable, .notAvailable, .serviceUnavailable,
             .unrecognisedAPIError, .decodingError:
            return String(localized: .DVLA.registrationLookupServiceUnavailable)
        }
    }

    private(set) var fetchedVehicle: VehicleEnquiryResponse.Vehicle?

    var clearsErrorOnAnyEdit = true

    let maxCharacters: Int

    private let lookupService: VehicleLookup
    private let onSuccess: (VehicleEnquiryResponse.Vehicle) -> Void
    private let onCancel: () -> Void

    init(maxCharacters: Int = 7,
         lookupService: @escaping VehicleLookup,
         onSuccess: @escaping (VehicleEnquiryResponse.Vehicle) -> Void,
         onCancel: @escaping () -> Void) {
        self.maxCharacters = maxCharacters
        self.lookupService = lookupService
        self.onSuccess = onSuccess
        self.onCancel = onCancel
    }

    var isValidPlate: Bool {
        let count = numberPlate.filter { $0.isLetter || $0.isNumber }.count
        return count >= 2 && count <= maxCharacters
    }

    private func alphanumericCount(_ value: String) -> Int {
        value.filter { $0.isLetter || $0.isNumber }.count
    }

    func submit() {
        submitTask?.cancel()
        submitTask = Task {
            await performSubmit()
        }
    }

    func cancel() {
        onCancel()
    }

    func performSubmit() async {
        guard isValidPlate, !isLoading else { return }

        let trimmed = numberPlate.trimmingCharacters(in: .whitespaces)
        isLoading = true
        error = nil
        fetchedVehicle = nil
        defer { isLoading = false }

        let result = await lookupService(trimmed)

        switch result {
        case .success(let vehicle):
            fetchedVehicle = vehicle
            isSubmitted = true
            onSuccess(vehicle)
        case .failure(let submitError):
            error = submitError
        }
    }
}
