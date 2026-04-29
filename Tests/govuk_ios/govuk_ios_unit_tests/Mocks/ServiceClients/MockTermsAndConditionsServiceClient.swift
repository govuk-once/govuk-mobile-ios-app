import Foundation

@testable import govuk_ios

class MockTermsAndConditionsServiceClient: TermsAndConditionsServiceClientInterface {
    var _stubbedTermsAndConditionsResponse:
    Result<TermsAndConditionsResponse, TermsAndConditionsError> = .success(
        TermsAndConditionsResponse.arrange(fileName: "MockTermsAndConditionsResponse")
    )

    func termsAndConditions(
        path: String
    ) async -> Result<TermsAndConditionsResponse, TermsAndConditionsError> {
        _stubbedTermsAndConditionsResponse
    }
}
