import Foundation
import Testing

@testable import govuk_ios

@Suite
struct TermsAndConditionsViewModelTests {

    @Test
    func primaryButton_action_savesDate_andCallCompletion() {
        let mockTermsAndConditionsService = MockTermsAndConditionsService()

        var completionCalled = false
        let sut = TermsAndConditionsViewModel(
            termsAndConditionsService: mockTermsAndConditionsService,
            completionAction: {
                completionCalled = true
            },
            alertDismissAction: { },
            openURLAction: { _ in }
        )

        sut.primaryButtonViewModel.action()

        #expect(mockTermsAndConditionsService._didSaveAcceptanceDate)
        #expect(completionCalled)
    }

    @Test
    func secondaryButton_action_setsAlert() {
        let mockTermsAndConditionsService = MockTermsAndConditionsService()

        let sut = TermsAndConditionsViewModel(
            termsAndConditionsService: mockTermsAndConditionsService,
            completionAction: { },
            alertDismissAction: { },
            openURLAction: { _ in }
        )

        sut.secondaryButtonViewModel.action()

        #expect(!mockTermsAndConditionsService._didSaveAcceptanceDate)
        #expect(sut.showAlert == true)
    }

    @Test
    func firstTimeUser_terms_showsCorrectTitleVariant() {
        let mockTermsAndConditionsService = MockTermsAndConditionsService()

        let sut = TermsAndConditionsViewModel(
            termsAndConditionsService: mockTermsAndConditionsService,
            completionAction: { },
            alertDismissAction: { },
            openURLAction: { _ in }
        )

        let expectedTitle = String(
            localized: LocalizedStringResource.TermsAndConditions.newTitle
        )
        #expect(sut.title == expectedTitle)
    }

    @Test
    func updatedTerms_showsCorrectTitleVariant() {
        let mockTermsAndConditionsService = MockTermsAndConditionsService()
        mockTermsAndConditionsService._stubbedHasUpdatedTerms = true

        let sut = TermsAndConditionsViewModel(
            termsAndConditionsService: mockTermsAndConditionsService,
            completionAction: { },
            alertDismissAction: { },
            openURLAction: { _ in }
        )

        let expectedTitle = String(
            localized: LocalizedStringResource.TermsAndConditions.updatedTitle
        )
        #expect(sut.title == expectedTitle)
    }
}
