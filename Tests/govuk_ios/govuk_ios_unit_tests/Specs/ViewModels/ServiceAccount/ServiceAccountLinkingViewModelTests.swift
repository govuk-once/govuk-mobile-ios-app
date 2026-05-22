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
    func init_dvla_createsCorrectTitle() {
        let sut = ServiceAccountLinkingViewModel(
            analyticsService: MockAnalyticsService(),
            userService: MockUserService(),
            accountType: .dvla,
            linkId: "",
            completeAction: {},
            dismissAction: {}
        )
        #expect(sut.title == "Adding driver and vehicles account…")
    }

    @Test
    func linkAccount_success_callsCompleteAction() {
        var didCallCompleteAction = false

        mockUserService._stubbedLinkAccountResult = .success(())
        let sut = ServiceAccountLinkingViewModel(
            analyticsService: MockAnalyticsService(),
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
    func linkAccount_apiUnavailable_setsCorrectErrorViewModel() throws {
        mockUserService._stubbedLinkAccountResult = .failure(.apiUnavailable)
        var wasDismissed = false
        let mockUrlOpener = MockURLOpener()
        let sut = ServiceAccountLinkingViewModel(
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            urlOpener: mockUrlOpener,
            accountType: .dvla,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {
                wasDismissed = true
            }
        )

        sut.linkAccount()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("genericErrorTitle"))
        #expect(errorViewModel.subtitle == "We could not add your driver and vehicles account. Try again later, or go to the GOV.UK website.")
        #expect(errorViewModel.primaryButtonTitle == "Go back to the driving topic")
        #expect(errorViewModel.secondaryButtonTitle == "Go to the GOV.UK website")
        errorViewModel.primaryButtonViewModel.action()
        #expect(wasDismissed == true)
        errorViewModel.secondaryButtonViewModel?.action()
        #expect(mockUrlOpener._receivedOpenIfPossibleUrl == Constants.API.govukBaseUrl)
    }

    @Test
    func linkAccount_networkUnavailable_setsCorrectErrorViewModel() throws {
        mockUserService._stubbedLinkAccountResult = .failure(.networkUnavailable)
        let sut = ServiceAccountLinkingViewModel(
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            accountType: .dvla,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {}
        )
        sut.linkAccount()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("networkUnavailableErrorTitle"))
        #expect(errorViewModel.subtitle == String.common.localized("networkUnavailableErrorBody"))
        #expect(errorViewModel.primaryButtonTitle == String.common.localized("networkUnavailableButtonTitle"))
        #expect(errorViewModel.secondaryButtonTitle == "")
        #expect(errorViewModel.systemImageName == nil)
        errorViewModel.primaryButtonViewModel.action()
        #expect(mockUserService._linkAccountCallCount == 2)
    }

    @Test
    func networkUnavailableError_action_tracksNavigationEvent() throws{
        let mockAnalyticsService = MockAnalyticsService()
        mockUserService._stubbedLinkAccountResult = .failure(.networkUnavailable)
        let sut = ServiceAccountLinkingViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            accountType: .dvla,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {}
        )
        sut.linkAccount()
        let errorViewModel = try #require(sut.errorViewModel)
        errorViewModel.primaryButtonViewModel.action()

        let event = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(event.name == "Navigation")
        #expect(event.params?["type"] as? String == "Button")
        #expect(event.params?["text"] as? String == String.common.localized("networkUnavailableButtonTitle"))
        #expect(event.params?["section"] as? String == "account link fail")
    }

    @Test
    func apiUnavailableError_primaryAction_tracksNavigationEvent() throws{
        let mockAnalyticsService = MockAnalyticsService()
        mockUserService._stubbedLinkAccountResult = .failure(.apiUnavailable)
        let sut = ServiceAccountLinkingViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            accountType: .dvla,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {}
        )
        sut.linkAccount()
        let errorViewModel = try #require(sut.errorViewModel)
        errorViewModel.primaryButtonViewModel.action()

        let event = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(event.name == "Navigation")
        #expect(event.params?["type"] as? String == "Button")
        #expect(event.params?["text"] as? String == "Go back to the driving topic")
        #expect(event.params?["section"] as? String == "account link fail")
    }

    func apiUnavailableError_secondaryAction_tracksNavigationEvent() throws{
        let mockAnalyticsService = MockAnalyticsService()
        mockUserService._stubbedLinkAccountResult = .failure(.apiUnavailable)
        let sut = ServiceAccountLinkingViewModel(
            analyticsService: mockAnalyticsService,
            userService: mockUserService,
            accountType: .dvla,
            linkId: "test-link-id",
            completeAction: {},
            dismissAction: {}
        )
        sut.linkAccount()
        let errorViewModel = try #require(sut.errorViewModel)
        errorViewModel.secondaryButtonViewModel?.action()

        let event = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(event.name == "Navigation")
        #expect(event.params?["type"] as? String == "Button")
        #expect(event.params?["external"] as? Bool == true)
        #expect(event.params?["url"] as? String == Constants.API.govukBaseUrl.absoluteString)
        #expect(event.params?["text"] as? String == "Go to the GOV.UK website")
        #expect(event.params?["section"] as? String == "account link fail")
    }

    @Test
    func dismiss_callsDismissAction() {
        var didCallDismissAction = false
        let sut = ServiceAccountLinkingViewModel(
            analyticsService: MockAnalyticsService(),
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
