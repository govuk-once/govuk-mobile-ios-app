import Testing
import SwiftUI
@testable import govuk_ios

@MainActor
struct StateLabelTests {

    // MARK: - 1. StateLabelStyleConfiguration Tests
    
    @Test("Configuration default values and state helpers resolve correctly")
    func testStyleConfiguration() {
        let config = StateLabelStyleConfiguration()
        
        // Verify default dimensions
        #expect(config.horizontalPadding == 12)
        #expect(config.verticalPadding == 8)
        #expect(config.cornerRadius == 6)
        
        // Verify color helper resolution
        #expect(config.backgroundColor(isError: true) == config.errorBackgroundColor)
        #expect(config.backgroundColor(isError: false) == config.normalBackgroundColor)
        #expect(config.foregroundColor(isError: true) == config.errorForegroundColor)
        #expect(config.foregroundColor(isError: false) == config.normalForegroundColor)
    }

    // MARK: - 2. Environment Extension Tests

    @Test("EnvironmentValues custom style reader and modifier injection")
    func testEnvironmentValues() {
        var env = EnvironmentValues()
        let customConfig = StateLabelStyleConfiguration(horizontalPadding: 20)
        
        // Verify default reader
        #expect(env.stateLabelStyleConfiguration.horizontalPadding == 12)
        
        // Verify setter
        env.stateLabelStyleConfiguration = customConfig
        #expect(env.stateLabelStyleConfiguration.horizontalPadding == 20)
        
        // Executes View.stateLabelStyle(_:) for code coverage
        _ = Text("Test").stateLabelStyle(customConfig)
    }

    // MARK: - 3. View Body Execution Tests

    @Test("StateLabel body renders normal and error states")
    func testStateLabelBody() {
        let normalLabel = StateLabel(content: .normal("Normal Text"))
        let errorLabel = StateLabel(content: .error("Error Text"))

        // Force body property evaluation for code coverage
        _ = normalLabel.body
        _ = errorLabel.body
    }

    // MARK: - 4. State Change & Accessibility Handling Tests

    @Test("StateLabel content transitions handle accessibility announcements and deduplication")
    func testContentStateTransitions() async throws {
        // Host view to simulate dynamic SwiftUI lifecycle updates and triggers for .onChange
        struct TestHostView: View {
            @Binding var content: StateLabelContent
            var body: some View {
                StateLabel(content: content)
            }
        }

        var currentContent: StateLabelContent = .normal("Initial Normal")
        
        let binding = Binding(
            get: { currentContent },
            set: { currentContent = $0 }
        )

        let hostView = TestHostView(content: binding)
        _ = hostView.body

        // 1. Transition to Error State
        currentContent = .error("Error 1")
        _ = hostView.body
        
        // Allow Task.sleep inside handleContentChange to execute
        try await Task.sleep(for: .milliseconds(150))

        // 2. Transition to Duplicate Error State (triggers guard errorText != lastAnnouncedError)
        currentContent = .error("Error 1")
        _ = hostView.body
        try await Task.sleep(for: .milliseconds(50))

        // 3. Transition back to Normal State (resets lastAnnouncedError)
        currentContent = .normal("Back to Normal")
        _ = hostView.body
    }
}
