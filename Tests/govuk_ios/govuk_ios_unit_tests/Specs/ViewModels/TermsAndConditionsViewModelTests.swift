import Foundation
import Testing

@testable import govuk_ios

@Suite
struct TermsAndConditionsViewModelTests {

    @Test
    func primaryButton_savesDate_andCallCompletion() {
        let mockAnalyticsService = MockAnalyticsService()
        let mockTermsAndConditionsService = MockTermsAndConditionsService()

        var completionCalled = false
        let sut = TermsAndConditionsViewModel(
            analyticsService: mockAnalyticsService,
            termsAndConditionsService: mockTermsAndConditionsService,
            completionAction: {
                completionCalled = true
            },
            dismissAction: { },
            openURLAction: { _ in }
        )

        sut.primaryButtonViewModel.action()

        #expect(mockTermsAndConditionsService._didSaveAcceptanceDate)
        #expect(completionCalled)
    }

    @Test
    func secondaryButton_callsDismiss() {
        let mockAnalyticsService = MockAnalyticsService()
        let mockTermsAndConditionsService = MockTermsAndConditionsService()

        var dismissCalled = false
        let sut = TermsAndConditionsViewModel(
            analyticsService: mockAnalyticsService,
            termsAndConditionsService: mockTermsAndConditionsService,
            completionAction: { },
            dismissAction: {
                dismissCalled = true
            },
            openURLAction: { _ in }
        )

        sut.secondaryButtonViewModel?.action()

        #expect(!mockTermsAndConditionsService._didSaveAcceptanceDate)
        #expect(dismissCalled)
    }

    @Test
    func firstTimeUser_terms_showsCorrectTitleVariant() {
        let mockAnalyticsService = MockAnalyticsService()
        let mockTermsAndConditionsService = MockTermsAndConditionsService()

        let sut = TermsAndConditionsViewModel(
            analyticsService: mockAnalyticsService,
            termsAndConditionsService: mockTermsAndConditionsService,
            completionAction: { },
            dismissAction: { },
            openURLAction: { _ in }
        )

        let expectedTitle = String(
            localized: LocalizedStringResource.TermsAndConditions.newTitle
        )
        #expect(sut.title == expectedTitle)
    }

    @Test
    func updatedTerms_showsCorrectTitleVariant() {
        let mockAnalyticsService = MockAnalyticsService()
        let mockTermsAndConditionsService = MockTermsAndConditionsService()
        mockTermsAndConditionsService._stubbedHasUpdatedTerms = true

        let sut = TermsAndConditionsViewModel(
            analyticsService: mockAnalyticsService,
            termsAndConditionsService: mockTermsAndConditionsService,
            completionAction: { },
            dismissAction: { },
            openURLAction: { _ in }
        )

        let expectedTitle = String(
            localized: LocalizedStringResource.TermsAndConditions.updatedTitle
        )
        #expect(sut.title == expectedTitle)
    }
}
