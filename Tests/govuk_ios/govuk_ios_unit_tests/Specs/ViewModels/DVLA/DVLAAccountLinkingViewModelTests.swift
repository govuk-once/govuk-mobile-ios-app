import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@Suite
struct DVLAAccountLinkingViewModelTests {

    var mockDvlaService: MockDVLAService

    init() {
        mockDvlaService = MockDVLAService()
    }
    
    @Test
    func linkAccount_success_callsCompleteAction() async {
        var didCallCompleteAction = false

        mockDvlaService._stubbedLinkAccountResult = .success(())
        let sut = DVLAAccountLinkingViewModel(
            dvlaService: mockDvlaService,
            linkId: "test-link-id",
            completeAction: {
                didCallCompleteAction = true
            },
            dismissAction: {}
        )

        sut.linkAccount()
        #expect(didCallCompleteAction == true)

    }

    @Test
    func linkAccount_authenticationError_setsErrorViewModel() async throws {
        mockDvlaService._stubbedLinkAccountResult = .failure(.authenticationError)
        let sut = DVLAAccountLinkingViewModel(
            dvlaService: mockDvlaService,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {}
        )

        sut.linkAccount()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("genericErrorTitle"))
        #expect(errorViewModel.body == String.dvla.localized("accountLinkingErrorBody"))
        #expect(errorViewModel.buttonTitle == String.dvla.localized("accountLinkingErrorButtonTitle"))
        #expect(errorViewModel.buttonAccessibilityLabel == String.dvla.localized(
            "accountLinkingErrorButtonTitle"
        ))
        #expect(errorViewModel.isWebLink == false)

        errorViewModel.action?()
        #expect(mockDvlaService._linkAccountCallCount == 2)
    }

    @Test
    func dismiss_callsDismissAction() {
        var didCallDismissAction = false
        let sut = DVLAAccountLinkingViewModel(
            dvlaService: mockDvlaService,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {
                didCallDismissAction = true
            }
        )
        sut.dismiss()
        #expect(didCallDismissAction == true)
    }
}
