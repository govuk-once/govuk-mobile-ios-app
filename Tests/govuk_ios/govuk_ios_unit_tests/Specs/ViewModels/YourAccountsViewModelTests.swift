import Testing
@testable import govuk_ios

@Suite
struct YourAccountsViewModelTests {

    @Test
    func fetchAccountLinkStatus_success_updatesStateCorrectly() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchAccountLinkStatusResult = .success(.arrangeLinked)

        let sut = YourAccountsViewViewModel(
            userService: mockUserService,
            dismissAction: {}
        )
        await sut.fetchAccountLinkStatus()
        #expect(sut.state == .success)
    }


    @Test
    func fetchAccountLinkStatus_failure_updatesStateCorrectly() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchAccountLinkStatusResult = .failure(.apiUnavailable)
        let sut = YourAccountsViewViewModel(
            userService: mockUserService,
            dismissAction: {}
        )
        await sut.fetchAccountLinkStatus()
        #expect(sut.state == .failure)
    }

}
