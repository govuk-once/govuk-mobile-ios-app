import Foundation
import Testing

@testable import govuk_ios

@Suite
struct AppConfigErrorTests {
    @Test
    func remoteJson_asAppUnavailableError_returnsAppConfigError() {
        let subject = AppConfigError.remoteJson
        let result = subject.asAppUnavailableError()

        #expect(result == AppUnavailableError.appConfig)
    }

    @Test
    func invalidSignature_asAppUnavailableError_returnsAppConfigError() {
        let subject = AppConfigError.invalidSignature
        let result = subject.asAppUnavailableError()

        #expect(result == AppUnavailableError.appConfig)
    }

    @Test
    func networkUnavailable_asAppUnavailableError_returnsNetworkUnavailable() {
        let subject = AppConfigError.networkUnavailable
        let result = subject.asAppUnavailableError()

        #expect(result == AppUnavailableError.networkUnavailable)
    }
}
