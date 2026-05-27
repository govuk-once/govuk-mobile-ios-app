import Testing
@testable import govuk_ios

struct YourAccountsViewModelTests {

    @Test
    func fetchLinkStatus_success_updatesStateCorrectly() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchAccountLinkStatusResult = .success(.arrangeLinked)

        let sut = YourAccountsViewViewModel(
            userService: mockUserService,
            dismissAction: {}
        )
        await sut.fetchLinkStatus()
        #expect(sut.state == .success)
    }


    @Test
    func fetchLinkStatus_failure_updatesStateCorrectly() async throws {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchAccountLinkStatusResult = .failure(.apiUnavailable)
        let sut = YourAccountsViewViewModel(
            userService: mockUserService,
            dismissAction: {}
        )
        #expect(sut.state == .failure)
    }

}
