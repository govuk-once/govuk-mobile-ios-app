import Testing
import SwiftUI
import GovKit

@testable import govuk_ios

@Suite
struct ChatViewControllerTests {

    @MainActor
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
