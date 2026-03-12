import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@Suite
struct ServiceAccountLinkingViewModelTests {

    var mockUserService: MockUserService

    init() {
        mockUserService = MockUserService()
    }
    
    @Test
    func linkAccount_success_callsCompleteAction() async {
        var didCallCompleteAction = false

        mockUserService._stubbedLinkAccountResult = .success(())
        let sut = ServiceAccountLinkingViewModel(
            userService: mockUserService,
            accountType: .dvla,
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
        mockUserService._stubbedLinkAccountResult = .failure(.authenticationError)
        let sut = ServiceAccountLinkingViewModel(
            userService: mockUserService,
            accountType: .dvla,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {}
        )

        sut.linkAccount()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("genericErrorTitle"))
        #expect(errorViewModel.body == String.serviceAccount.localized("accountLinkingErrorBody"))
        #expect(errorViewModel.buttonTitle == String.serviceAccount.localized("accountLinkingErrorButtonTitle"))
        #expect(errorViewModel.buttonAccessibilityLabel == String.serviceAccount.localized(
            "accountLinkingErrorButtonTitle"
        ))
        #expect(errorViewModel.isWebLink == false)

        errorViewModel.action?()
        #expect(mockUserService._linkAccountCallCount == 2)
    }

    @Test
    func dismiss_callsDismissAction() {
        var didCallDismissAction = false
        let sut = ServiceAccountLinkingViewModel(
            userService: mockUserService,
            accountType: .dvla,
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
