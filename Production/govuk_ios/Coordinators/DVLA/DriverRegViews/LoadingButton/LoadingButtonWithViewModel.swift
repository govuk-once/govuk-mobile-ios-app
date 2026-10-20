import SwiftUI

/// A custom button style that displays a loading spinner instead of the label
/// when `isLoading` is true, providing smooth state transitions.
struct LoadingButtonStyle: ButtonStyle {
    let isLoading: Bool

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            } else {
                configuration.label
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isLoading ? Color.blue.opacity(0.6) : Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        .scaleEffect(configuration.isPressed && !isLoading ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}
