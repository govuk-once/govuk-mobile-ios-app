import SwiftUI
import Combine

enum PlateSubmitError: String, CaseIterable, Hashable {
    case serviceUnavailable = "Search not working - try again later"
    case notFound = "Number plate not found"
}

/// Owns plate input state, validation, and submission. Inject into any view that hosts a ``DrivingLicenseField``.
@MainActor
final class PlateFormViewModel: ObservableObject {
    @Published var numberPlate: String = "" {
        // Clears the error when the user edits the plate, so they can retry after a failed submission.
        // Compares sanitized forms to ignore the intermediate value from the sanitizer bounce-back
        // (e.g. typing an 8th char briefly sets "AB12 CDEX" before sanitizing back to "AB12 CDE").
        didSet {
            guard error != nil else { return }
            let oldClean = PlateFormatter.sanitize(oldValue, maxAlphanumerics: maxCharacters)
            let newClean = PlateFormatter.sanitize(numberPlate, maxAlphanumerics: maxCharacters)
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
    @Published private(set) var error: PlateSubmitError?

    var simulatedError: PlateSubmitError?
    var clearsErrorOnAnyEdit = true

    let maxCharacters: Int

    init(maxCharacters: Int = 7) {
        self.maxCharacters = maxCharacters
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
        defer { isLoading = false }

        try? await Task.sleep(for: .seconds(2))

        if let simulatedError {
            error = simulatedError
            return false
        }

        print("Submitted plate: \(trimmed)")
        isSubmitted = true
        return true
    }
}
