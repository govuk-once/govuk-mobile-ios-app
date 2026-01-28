import Foundation
import Testing

@testable import govuk_ios

@Suite
struct UserStateErrorTests {
    @Test
    func apiUnavailable_asAppUnavailableError_returnsUserStateError() {
        let subject = UserStateError.apiUnavailable
        let result = subject.asAppUnavailableError()

        #expect(result == AppUnavailableError.userState)
    }

    @Test
    func decodingError_asAppUnavailableError_returnsUserStateError() {
        let subject = UserStateError.decodingError
        let result = subject.asAppUnavailableError()

        #expect(result == AppUnavailableError.userState)
    }

    @Test
    func authenticationError_asAppUnavailableError_returnsUserStateError() {
        let subject = UserStateError.authenticationError
        let result = subject.asAppUnavailableError()

        #expect(result == AppUnavailableError.userState)
    }

    @Test
    func networkUnavailable_asAppUnavailableError_returnsNetworkUnavailable() {
        let subject = UserStateError.networkUnavailable
        let result = subject.asAppUnavailableError()

        #expect(result == AppUnavailableError.networkUnavailable)
    }
}

