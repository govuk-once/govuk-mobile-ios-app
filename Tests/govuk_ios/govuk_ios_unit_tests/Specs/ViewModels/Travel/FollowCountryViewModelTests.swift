import Foundation
import Testing

@testable import govuk_ios

@Suite
struct FollowCountryViewModelTests {

    @Test
    func dismissAction_executesClosure() {
        var didCallDismiss = false
        
        let viewModel = FollowCountryViewModel(dismissAction: {
            didCallDismiss = true
        })
        
        viewModel.dismissAction()
        
        #expect(didCallDismiss == true)
    }

    @Test
    func dismissAction_executesMultipleCalls() {
        var callCount = 0
        
        let viewModel = FollowCountryViewModel(dismissAction: {
            callCount += 1
        })
        
        viewModel.dismissAction()
        viewModel.dismissAction()
        
        #expect(callCount == 2)
    }
}
