import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@Suite
struct ServiceAccountUnlinkingViewModelTests {

    var mockUserService: MockUserService

    init() {
        mockUserService = MockUserService()
    }

    @Test
    func unlinkAccount_success_callsCompleteAction() async {
        var didCallCompleteAction = false

        mockUserService._stubbedUnlinkAccountResult = .success(())
        let sut = ServiceAccountUnlinkingViewModel(
            userService: mockUserService,
            accountType: .dvla,
            completeAction: {
                didCallCompleteAction = true
            },
            dismissAction: {}
        )

        sut.unlinkAccount()
        #expect(didCallCompleteAction == true)

    }

    @Test
    func unlinkAccount_authenticationError_setsErrorViewModel() async throws {
        mockUserService._stubbedUnlinkAccountResult = .failure(.authenticationError)
        let sut = ServiceAccountUnlinkingViewModel(
            userService: mockUserService,
            accountType: .dvla,
            completeAction: {},
            dismissAction: {}
        )

        sut.unlinkAccount()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("genericErrorTitle"))
        #expect(errorViewModel.body == String.serviceAccount.localized("accountUnlinkingErrorBody"))
        #expect(errorViewModel.buttonTitle == String.serviceAccount.localized("accountLinkingErrorButtonTitle"))
        #expect(errorViewModel.buttonAccessibilityLabel == String.serviceAccount.localized(
            "accountLinkingErrorButtonTitle"
        ))
        #expect(errorViewModel.isWebLink == false)

        errorViewModel.action?()
        #expect(mockUserService._unlinkAccountCallCount == 2)
    }

    @Test
    func dismiss_callsDismissAction() {
        var didCallDismissAction = false
        let sut = ServiceAccountUnlinkingViewModel(
            userService: mockUserService,
            accountType: .dvla,
            completeAction: {},
            dismissAction: {
                didCallDismissAction = true
            }
        )
        sut.dismiss()
        #expect(didCallDismissAction == true)
    }
}
