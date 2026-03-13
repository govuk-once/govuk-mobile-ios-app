import Foundation
import GovKit
import Testing

@testable import govuk_ios

struct WelcomeOnboardingViewModelTests {
    @Test
    func primaryButtonViewModel_action_completesAction() async {
        let completion = await withCheckedContinuation { continuation in
            let sut = WelcomeOnboardingViewModel(
                completeAction: { continuation.resume(returning: true) },
                openURLAction: { _ in },
                termsURL: Constants.API.govukBaseUrl
            )
            let buttonViewModel = sut.primaryButtonViewModel
            buttonViewModel.action()
        }
        #expect(completion)
    }
}
