import Testing
import UIKit

@testable import govuk_ios

@Suite
struct ChatTermsOnboardingViewModelTests {

    @Test
    func primaryButtonViewModel_action_callCompletion() {
        let mockChatService = MockChatService()
        let sut = ChatTermsOnboardingViewModel(
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            cancelOnboardingAction: { },
            completionAction: { },
            openURLAction: { _ in }
        )

        #expect(!mockChatService.chatOnboardingSeen)
        sut.primaryButtonViewModel.action()
        #expect(mockChatService.chatOnboardingSeen)
    }

    @Test
    func primaryButtonViewModel_action_tracksEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = ChatTermsOnboardingViewModel(
            analyticsService: mockAnalyticsService,
            chatService: MockChatService(),
            cancelOnboardingAction: { },
            completionAction: { },
            openURLAction: { _ in }
        )

        sut.primaryButtonViewModel.action()

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "Agree and continue")
    }

    @Test
    func secondaryButtonViewModel_action_cancelsOnboarding() {
        var didCancelOnboarding = false
        let mockChatService = MockChatService()
        let sut = ChatTermsOnboardingViewModel(
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            cancelOnboardingAction: {
                didCancelOnboarding = true
            },
            completionAction: { },
            openURLAction: { _ in }
        )

        #expect(!mockChatService.chatOnboardingSeen)
        sut.secondaryButtonViewModel?.action()
        #expect(!mockChatService.chatOnboardingSeen)
        #expect(didCancelOnboarding)
    }

    @Test
    func secondaryButtonViewModel_action_tracksEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = ChatTermsOnboardingViewModel(
            analyticsService: mockAnalyticsService,
            chatService: MockChatService(),
            cancelOnboardingAction: { },
            completionAction: { },
            openURLAction: { _ in }
        )

        sut.secondaryButtonViewModel?.action()

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "Exit GOV.UK Chat")
    }

    @Test
    func openTermsURLAction_action_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        let mockChatService = MockChatService()
        await confirmation() { confirmation in
            let sut = ChatTermsOnboardingViewModel(
                analyticsService: mockAnalyticsService,
                chatService: mockChatService,
                cancelOnboardingAction: { },
                completionAction: { },
                openURLAction: { _ in  confirmation() }
            )

            sut.openTermsURLAction(url: mockChatService.privacyPolicy)

            #expect(mockAnalyticsService._trackedEvents.count == 1)
            #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "privacy notice")
        }
    }
}
