import SwiftUI

// MARK: - Style Configuration Struct
struct StateLabelStyleConfiguration {
    var font: Font = .body
    var horizontalPadding: CGFloat = 12
    var verticalPadding: CGFloat = 8
    var cornerRadius: CGFloat = 8

    // Color definitions
    var errorBackgroundColor: Color = Color(
        UIColor.yellowTint80
    )
    var normalBackgroundColor: Color = Color(
        .govUK.fills.surfaceCardDefault
    )
    var errorForegroundColor: Color = Color(
        UIColor.govUK.text.primary
    )
    var normalForegroundColor: Color = Color(
        UIColor.govUK.text.primary
    )

    // Helper functions for state-based resolution
    func backgroundColor(isError: Bool) -> Color {
        isError ? errorBackgroundColor : normalBackgroundColor
    }

    func foregroundColor(isError: Bool) -> Color {
        isError ? errorForegroundColor : normalForegroundColor
    }
}

// MARK: Environment Key Setup
private struct StateLabelStyleConfigKey: EnvironmentKey {
    static let defaultValue = StateLabelStyleConfiguration()
}

extension EnvironmentValues {
    var stateLabelStyleConfiguration: StateLabelStyleConfiguration {
        get { self[StateLabelStyleConfigKey.self] }
        set { self[StateLabelStyleConfigKey.self] = newValue }
    }
}

// Parent view extension to inject style changes down the hierarchy
extension View {
    func stateLabelStyle(_ configuration: StateLabelStyleConfiguration) -> some View {
        environment(\.stateLabelStyleConfiguration, configuration)
    }
}

// MARK: - StateLabel Component
struct StateLabel: View {
    let content: StateLabelContent

    @Environment(\.stateLabelStyleConfiguration) private var style
    @State private var lastAnnouncedError: String = ""

    var body: some View {
        Text(content.text)
            .font(style.font)
            .padding(.horizontal, style.horizontalPadding)
            .padding(.vertical, style.verticalPadding)
            .background(style.backgroundColor(isError: content.isError))
            .foregroundColor(style.foregroundColor(isError: content.isError))
            .cornerRadius(style.cornerRadius)
            .animation(.easeInOut(duration: 0.2), value: content)
            .accessibilityLabel(content.text)
            .accessibilityAddTraits(.updatesFrequently)
            .onChange(of: content) { newContent in
                handleContentChange(newContent)
            }
    }

    private func handleContentChange(_ newContent: StateLabelContent) {
        switch newContent {
        case .error(let errorText):
            guard errorText != lastAnnouncedError else { return }
            lastAnnouncedError = errorText

            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(100))
                UIAccessibility.post(
                    notification: .announcement,
                    argument: errorText
                )
            }

        case .normal:
            lastAnnouncedError = ""
        }
    }
}

#Preview("StateLabel") {
    VStack {
        StateLabel(content: .normal("normal content"))
        StateLabel(content: .error("error content"))
    }
}
