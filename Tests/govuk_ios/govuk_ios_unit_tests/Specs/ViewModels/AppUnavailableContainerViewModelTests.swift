import Foundation
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct AppUnavailableViewModelTests {
    @Test
    func init_appConfigUnavailable_hasCorrectInitialState()  {
        let sut = AppUnavailableContainerViewModel(
            error: .appConfig,
            retryAction: { _ in },
            dismissAction: { }
        )

        #expect(sut.title == "Sorry, the app is unavailable")
        #expect(sut.subheading == "You cannot use the GOV.UK app at the moment. Try again later.")
        #expect(sut.buttonTitle == "Go to the GOV.UK website ↗")
        #expect(sut.buttonAccessibilityTitle == "Go to the GOV.UK website")
        #expect(sut.buttonAccessibilityHint == "Opens in web browser")
    }

    @Test
    func init_userStateUnavailable_hasCorrectInitialState()  {
        let sut = AppUnavailableContainerViewModel(
            error: .userState,
            retryAction: { _ in },
            dismissAction: { }
        )

        #expect(sut.title == "Sorry, the app is unavailable")
        #expect(sut.subheading == "You cannot use the GOV.UK app at the moment. Try again later.")
        #expect(sut.buttonTitle == "Go to the GOV.UK website ↗")
        #expect(sut.buttonAccessibilityTitle == "Go to the GOV.UK website")
        #expect(sut.buttonAccessibilityHint == "Opens in web browser")
    }

    @Test
    func init_networkUnavailable_hasCorrectInitialState()  {
        let sut = AppUnavailableContainerViewModel(
            error: .networkUnavailable,
            retryAction: { _ in },
            dismissAction: { }
        )


        #expect(sut.title == "You are not connected to the internet")
        #expect(sut.subheading ==
            """
            You need to have an internet connection to use the GOV.UK app. 

            Reconnect to the internet and try again.
            """
        )
        #expect(sut.buttonTitle == "Try again")
        #expect(sut.buttonAccessibilityTitle == "Try again")
        #expect(sut.buttonAccessibilityHint == "")
    }

    @Test
    func goToGovUkButtonAction_opensURL() {
        let urlOpener = MockURLOpener()
        let sut = AppUnavailableContainerViewModel(
            urlOpener: urlOpener,
            error: .appConfig,
            retryAction: { _ in },
            dismissAction: { }
        )
        sut.buttonViewModel.action()
        #expect(urlOpener._receivedOpenIfPossibleUrl == Constants.API.govukBaseUrl)
    }

    @Test
    func tryAgainButtonAction_successfulRetry_dismisses() {
        let urlOpener = MockURLOpener()
        var didDismiss = false
        let sut = AppUnavailableContainerViewModel(
            urlOpener: urlOpener,
            error: .networkUnavailable,
            retryAction: { completion in
                completion(true)
            },
            dismissAction: {
                didDismiss = true
            }
        )
        sut.buttonViewModel.action()
        #expect(didDismiss)
    }

    @Test
    func tryAgainButtonAction_retryUnsuccessful_doesNot_dismiss() {
        let urlOpener = MockURLOpener()
        var didDismiss = false
        let sut = AppUnavailableContainerViewModel(
            urlOpener: urlOpener,
            error: .networkUnavailable,
            retryAction: { completion in
                completion(false)
            },
            dismissAction: {
                didDismiss = true
            }
        )
        sut.buttonViewModel.action()
        #expect(!didDismiss)
    }
}
