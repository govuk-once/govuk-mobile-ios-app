import Foundation

@testable import govuk_ios

final class MockTermsAndConditionsService: TermsAndConditionsServiceInterface {
    var _stubbedTermsAcceptanceIsValid: Bool = false
    var termsAcceptanceIsValid: Bool {
        _stubbedTermsAcceptanceIsValid
    }

    var _stubbedTermsAndConditionsURL: URL = URL(string: "https://www.example.com")!
    var termsAndConditionsURL: URL {
        _stubbedTermsAndConditionsURL
    }

    var _stubbedHasUpdatedTerms: Bool = false
    var hasUpdatedTerms: Bool {
        _stubbedHasUpdatedTerms
    }

    var _didSaveAcceptanceDate: Bool = false
    func saveAcceptanceDate() {
        _didSaveAcceptanceDate = true
    }

    var _didResetAcceptanceDate: Bool = false
    func resetAcceptanceDate() {
        _didResetAcceptanceDate = true
    }
}
