import SwiftUI
import Combine

enum RegistrationNumberQueryError: String, Error, CaseIterable, Hashable {
    case serviceUnavailable = "Search not working - try again later"
    case notFound = "Number plate not found"
}

typealias RegistrationNumberSubmitAction =
(String) async -> Result<
    VehicleEnquiryResponse.Vehicle,
        RegistrationNumberQueryError
>

/// Owns registration number input state, validation, and submission.
@MainActor
final class RegistrationNumberFormViewModel: ObservableObject {
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
    @Published private(set) var error: RegistrationNumberQueryError?
    private(set) var fetchedVehicle: VehicleEnquiryResponse.Vehicle?

    var clearsErrorOnAnyEdit = true

    let maxCharacters: Int
    private let submitAction: RegistrationNumberSubmitAction

    init(maxCharacters: Int = 7,
         submitAction: @escaping RegistrationNumberSubmitAction) {
        self.maxCharacters = maxCharacters
        self.submitAction = submitAction
    }

    var isValidPlate: Bool {
        let count = numberPlate.filter { $0.isLetter || $0.isNumber }.count
        return count >= 2 && count <= maxCharacters
    }

    private func alphanumericCount(_ value: String) -> Int {
        value.filter { $0.isLetter || $0.isNumber }.count
    }

    @discardableResult
    func submit() async -> Bool {
        let trimmed = numberPlate.trimmingCharacters(in: .whitespaces)
        isLoading = true
        error = nil
        fetchedVehicle = nil
        defer { isLoading = false }

        let result = await submitAction(trimmed)

        switch result {
        case .success(let vehicle):
            fetchedVehicle = vehicle
            isSubmitted = true
            return true
        case .failure(let submitError):
            error = submitError
            return false
        }
    }
}
