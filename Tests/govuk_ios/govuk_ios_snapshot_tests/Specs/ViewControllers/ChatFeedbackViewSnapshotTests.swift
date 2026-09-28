import Foundation
import XCTest
import SwiftUI
import GovKit
import GovKitUI

@testable import govuk_ios

final class ChatFeedbackViewSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_unrated_light_rendersCorrectly() {
        verify(feedbackView(), mode: .light)
    }

    func test_loadInNavigationController_unrated_dark_rendersCorrectly() {
        verify(feedbackView(), mode: .dark)
    }

    func test_loadInNavigationController_helpful_light_rendersCorrectly() {
        verify(feedbackView(isPositive: true), mode: .light)
    }

    func test_loadInNavigationController_helpful_dark_rendersCorrectly() {
        verify(feedbackView(isPositive: true), mode: .dark)
    }

    func test_loadInNavigationController_notHelpful_light_rendersCorrectly() {
        verify(feedbackView(isPositive: false), mode: .light)
    }

    func test_loadInNavigationController_notHelpful_dark_rendersCorrectly() {
        verify(feedbackView(isPositive: false), mode: .dark)
    }

    func test_loadInNavigationController_helpfulWithoutConsent_light_rendersCorrectly() {
        verify(feedbackView(isPositive: true, permissionState: .denied), mode: .light)
    }

    func test_loadInNavigationController_helpfulWithoutConsent_dark_rendersCorrectly() {
        verify(feedbackView(isPositive: true, permissionState: .denied), mode: .dark)
    }

    func test_loadInNavigationController_confirmed_light_rendersCorrectly() {
        verify(feedbackView(isPositive: true, isConfirmed: true), mode: .light)
    }

    func test_loadInNavigationController_confirmed_dark_rendersCorrectly() {
        verify(feedbackView(isPositive: true, isConfirmed: true), mode: .dark)
    }

    private func verify(_ view: some View,
                        mode: UIUserInterfaceStyle,
                        file: StaticString = #file,
                        line: UInt = #line) {
        VerifySnapshotInNavigationController(
            view: view,
            mode: mode,
            navBarHidden: true,
            file: file,
            line: line
        )
    }

    private func feedbackView(isPositive: Bool? = nil,
                              permissionState: AnalyticsPermissionState = .accepted,
                              isConfirmed: Bool = false) -> some View {
        let mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsService._stubbedPermissionState = permissionState
        let viewModel = ChatFeedbackViewModel(
            questionId: "questionId",
            analyticsService: mockAnalyticsService,
            scheduleConfirmation: { $0() }
        )
        if let isPositive {
            viewModel.rate(isPositive: isPositive)
        }
        if isConfirmed {
            viewModel.openSurvey()
        }
        return ChatFeedbackView(viewModel: viewModel)
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.govUK.fills.surfaceChatBackground))
            .environment(\.isTesting, true)
    }
}
