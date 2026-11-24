import Foundation

@testable import govuk_ios

final class MockLocalAuthorityRepository: LocalAuthorityRepositoryInterface {
    var _didDeleteLocalAuthorities = false
    func delete(completion: @escaping () -> Void) {
        _didDeleteLocalAuthorities = true
    }

    var _didSaveLocalAuthority = false
    func save(_ localAuthority: Authority) {
        _didSaveLocalAuthority = true
    }

    var _didFetchLocalAuthority = false
    func fetchLocalAuthority() -> [LocalAuthorityItem] {
        _didFetchLocalAuthority = true
        return []
    }
}
