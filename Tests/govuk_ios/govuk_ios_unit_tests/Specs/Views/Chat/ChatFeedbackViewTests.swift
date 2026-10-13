import Foundation
import SwiftUI
import Testing
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
@Suite(.serialized)
struct ChatFeedbackViewTests {

    @Test(arguments: [
        (true, "Helpful, selected"),
        (false, "Not helpful, selected")
    ])
    func rate_withConsent_announcesSelection(isPositive: Bool,
                                             expectedAnnouncement: String) async throws {
        let mockAccessibilityAnnouncer = MockAccessibilityAnnouncerService()
        let viewModel = makeViewModel(permissionState: .accepted)
        let window = makeWindow(
            viewModel: viewModel,
            accessibilityAnnouncer: mockAccessibilityAnnouncer
        )
        try await Task.sleep(for: .milliseconds(100))
        viewModel.rate(isPositive: isPositive)
        try await waitForAnnouncement(mockAccessibilityAnnouncer)

        #expect(mockAccessibilityAnnouncer._receivedAnnounceValue == expectedAnnouncement)
        window.isHidden = true
    }

    @Test
    func rate_withoutConsent_doesNotAnnounceSelection() async throws {
        let mockAccessibilityAnnouncer = MockAccessibilityAnnouncerService()
        let viewModel = makeViewModel(permissionState: .denied)
        let window = makeWindow(
            viewModel: viewModel,
            accessibilityAnnouncer: mockAccessibilityAnnouncer
        )
        try await Task.sleep(for: .milliseconds(100))
        viewModel.rate(isPositive: true)
        try await Task.sleep(for: .milliseconds(300))

        #expect(viewModel.state == .confirmed)
        #expect(mockAccessibilityAnnouncer._receivedAnnounceValue == nil)
        window.isHidden = true
    }

    private func makeViewModel(permissionState: AnalyticsPermissionState) -> ChatFeedbackViewModel {
        let mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsService._stubbedPermissionState = permissionState
        return ChatFeedbackViewModel(
            questionId: "questionId",
            analyticsService: mockAnalyticsService
        )
    }

    private func makeWindow(viewModel: ChatFeedbackViewModel,
                            accessibilityAnnouncer: MockAccessibilityAnnouncerService) -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(
            rootView: ChatFeedbackView(
                viewModel: viewModel,
                accessibilityAnnouncer: accessibilityAnnouncer
            )
        )
        window.isHidden = false
        return window
    }

    private func waitForAnnouncement(_ announcer: MockAccessibilityAnnouncerService) async throws {
        for _ in 0..<100 where announcer._receivedAnnounceValue == nil {
            try await Task.sleep(for: .milliseconds(20))
        }
    }
}
