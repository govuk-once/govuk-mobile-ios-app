import Testing
@testable import govuk_ios

@Suite
struct YourAccountsViewModelTests {

    @Test
    func fetchLinkedAccounts_success_linked_updatesStateCorrectly() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchLinkedAccountsResult = .success([.dvla])

        let sut = YourAccountsViewViewModel(
            userService: mockUserService
        )
        await sut.fetchLinkedAccounts()
        #expect(sut.state == .success)
    }

    @Test
    func fetchLinkedAccounts_success_unliked_updatesStateCorrectly() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchLinkedAccountsResult = .success([])

        let sut = YourAccountsViewViewModel(
            userService: mockUserService
        )
        await sut.fetchLinkedAccounts()
        #expect(sut.state == .empty)
    }


    @Test
    func fetchLinkedAccounts_failure_updatesStateCorrectly() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchLinkedAccountsResult = .failure(.apiUnavailable)
        let sut = YourAccountsViewViewModel(
            userService: mockUserService
        )
        await sut.fetchLinkedAccounts()
        #expect(sut.state == .failure)
    }

}
