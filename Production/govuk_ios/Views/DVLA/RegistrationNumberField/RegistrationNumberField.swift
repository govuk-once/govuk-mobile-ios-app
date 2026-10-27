import SwiftUI

/// A registration number (number plate) text input with built-in sanitisation and a clear button.
struct RegistrationNumberField: View {
    @Binding var text: String
    var maxCharacters: Int = 7

    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("", text: $text)
                .multilineTextAlignment(.center)
                .font(.govUK.vehicleRegistrationInputFieldText)
                .registrationNumberKeyboard()
                .onChange(of: text) { newValue in
                    let sanitized = RegistrationNumberFormatter.sanitize(
                        newValue,
                        maxAlphanumerics: maxCharacters
                    )
                    if text != sanitized {
                        text = sanitized
                    }
                }

            if !text.isEmpty {
                clearButton
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: text.isEmpty)
    }

    private var clearButton: some View {
        Button {
            text = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.primary)
        }
        .accessibilityLabel(.DVLA.clearTextAccessibilityLabel)
        .transition(.opacity.combined(with: .scale))
    }
}

/// Configures the keyboard for registration number entry: uppercase, ASCII-only, no autocorrect.
private struct RegistrationNumberModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textInputAutocapitalization(.characters)
            .keyboardType(.asciiCapable)
            .autocorrectionDisabled()
    }
}

extension View {
    func registrationNumberKeyboard() -> some View {
        modifier(RegistrationNumberModifier())
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text = "AB12 CDE"
        var body: some View {
            RegistrationNumberField(text: $text)
                .padding()
        }
    }
    return PreviewWrapper()
}
