import SwiftUI
import GovKitUI

/// A custom button style that displays a loading spinner instead of the label
/// when `isLoading` is true, providing smooth state transitions.
struct LoadingButtonStyle: ButtonStyle {
    let isLoading: Bool
    var loadingLabel: String

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .opacity(isLoading ? 1.0 : 0.0)
                .accessibilityHidden(!isLoading)
                .accessibilityLabel(loadingLabel)
            configuration.label
                .opacity(labelOpacity(isPressed: configuration.isPressed))
        }
        .frame(maxWidth: .infinity, idealHeight: 44)
        .padding()
        .background(Color(uiColor: .primaryBlue))
        .foregroundColor(.white)
        .cornerRadius(15)
        .scaleEffect(configuration.isPressed && !isLoading ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }

    private func labelOpacity(isPressed: Bool) -> Double {
        if isLoading { return 0 }
        return isPressed ? 0.7 : 1.0
    }
}

#Preview("LoadingButton") {
    VStack {
        Button("Do it") {}
        .buttonStyle(
            LoadingButtonStyle(isLoading: false,
                               loadingLabel: "")
        )

        Button("Wait for it") {}
        .buttonStyle(
            LoadingButtonStyle(isLoading: true,
                               loadingLabel: "Wait for it")
        )
    }
    .padding(.horizontal)
}
