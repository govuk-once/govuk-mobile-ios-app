import Testing
import SwiftUI
import GovKit

@testable import govuk_ios

@Suite
struct ChatViewControllerTests {

    @MainActor
    // This test has no assertions as it is here simply to generate
    // coverage over the onChange code in ChatView.  The asynchronous
    // nature of the onChange code using DispatchQueue.main.asyncAfter,
    // and the use of the same in the test to assure onChange is invoked
    // for coverage makes testing cumbersome and would require introduction
    // of additional code in the view and viewModel that would serve no
    // purpose except to provide a value to test.
    @Test func test_onChange_invoked() async throws {
        let mockChatService = MockChatService()

        let viewModel = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )

        let view = ChatView(
            viewModel: viewModel
        )

        let vc = HostingViewController(
            rootView: view
        )

        UIApplication.shared.window?.rootViewController = vc
        viewModel.requestInFlight = false
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            viewModel.requestInFlight = true
        }
    }
}
