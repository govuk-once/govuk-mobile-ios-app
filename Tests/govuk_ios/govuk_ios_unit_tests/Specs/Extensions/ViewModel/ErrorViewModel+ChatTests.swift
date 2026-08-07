import Testing
import UIKit

@testable import govuk_ios
@testable import GovKit
@testable import GovKitUI

struct ErrorViewModel_ChatTests {
    @Test
    func hasCorrectStyle_forNetworkError() {
        let sut = ErrorViewModel.chatError(
            .networkUnavailable,
            analyticsService: MockAnalyticsService(),
            action: {}
        )

        #expect(sut.title == String.common.localized("networkUnavailableErrorTitle"))
        #expect(sut.subtitle == String.common.localized("networkUnavailableErrorBody"))
        #expect(sut.primaryButtonTitle == String.common.localized("networkUnavailableButtonTitle"))
        #expect(sut.showPrimaryButton)
    }

    @Test
    func hasCorrectStyle_forPageNotFoundError() {
        let sut = ErrorViewModel.chatError(
            .pageNotFound,
            analyticsService: MockAnalyticsService(),
            action: {}
        )

        #expect(sut.title == String.common.localized("genericErrorTitle"))
        #expect(sut.subtitle == String.chat.localized("pageNotFoundErrorBody"))
        #expect(sut.primaryButtonTitle == String.chat.localized("pageNotFoundButtonTitle"))
        #expect(sut.showPrimaryButton)
    }

    @Test
    func hasCorrectStyle_forOtherError() {
        let sut = ErrorViewModel.chatError(
            .apiUnavailable,
            analyticsService: MockAnalyticsService(),
            action: {}
        )

        #expect(sut.title == String.common.localized("genericErrorTitle"))
        #expect(sut.subtitle == String.chat.localized("genericErrorBody"))
        #expect(sut.primaryButtonTitle == "")
        #expect(!sut.showPrimaryButton)
    }
}
