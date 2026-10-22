// KK: breadcrumb

import SwiftUI

/*
struct PlaceholderView: View {
    var body: some View {
        ZStack {
            Color(.red)
            VStack {
                Text("Placeholder View")
            }
        }
        .frame(width: 320, height: 210) // Fixed size card
    }
}
*/
/*
struct PlaceholderView: View {
    @State private var inputText: String = ""
    @State private var keyboardHeight: CGFloat = 0

    var bottomSpacing: CGFloat = 0 // 16 // Desired distance above the keyboard
    var submitAction: (String) -> Void
    var cancelAction: () -> Void

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    cancelAction()
                }

            // Card aligned to the bottom, padded by keyboard height + desired spacing
            VStack {
                Spacer()

                VStack(spacing: 20) {
                    Text("Search or Enter Text")
                        .font(.headline)

                    TextField("Type here...", text: $inputText)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .submitLabel(.search)
                        .submitAction {
                            if !inputText.isEmpty { submitAction(inputText) }
                        }

                    HStack(spacing: 12) {
                        Button("Cancel") { cancelAction() }.buttonStyle(.bordered)
                        Button("Submit") { submitAction(inputText) }.buttonStyle(.borderedProminent)
                            .disabled(inputText.isEmpty)
                    }
                }
                .padding(24)
                .frame(width: 320) // Fixed width, flexible height
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 5)
                // Push up by the keyboard height plus your custom spacing
                .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + bottomSpacing : 50)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
                // We handle keyboard padding manually for smooth control
        }
        .onAppear {
            isTextFieldFocused = true
            setupKeyboardListeners()
        }
    }

    // Listen to keyboard notifications to get its exact height
    private func setupKeyboardListeners() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main) { notification in
            if let frame = notification.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? CGRect {
                withAnimation(.easeOut(duration: 0.25)) {
                    self.keyboardHeight = frame.height
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                self.keyboardHeight = 0
            }
        }
    }
}
 */

typealias PlaceholderVehicleSearchResult = String

struct PlaceholderView: View {
    @State private var inputText: String = "AA"

    var bottomSpacing: CGFloat = 16 // Desired distance above the keyboard
    var onSubmit: (String, [PlaceholderVehicleSearchResult]) -> Void
    var onCancel: () -> Void

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }

            // Card aligned to the bottom, automatically tracked by SwiftUI's keyboard layout
            VStack {
                Spacer()

                VStack(spacing: 20) {
                    Text("Search or Enter Text")
                        .font(.headline)

                    TextField("Type here...", text: $inputText)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            triggerSubmit()
                        }

                    HStack(spacing: 12) {
                        Button("Cancel") { onCancel() }
                            .buttonStyle(.bordered)

                        Button("Submit") { triggerSubmit() }
                            .buttonStyle(.borderedProminent)
                            .disabled(inputText.isEmpty)
                    }
                }
                .padding(24)
                .frame(width: 320) // Fixed width, flexible height
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 5)
                // This padding respects the keyboard automatically in modern SwiftUI
                .padding(.bottom, bottomSpacing)
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }

    private func triggerSubmit() {
        guard !inputText.isEmpty else { return }
        // Generate mock search results based on the input for now
        let mockResults = [
            "Result 1 for \(inputText)",
            "Result 2 for \(inputText)",
            "Result 3 for \(inputText)"
        ]
        onSubmit(inputText, mockResults)
    }
}
#Preview {
    PlaceholderView(onSubmit: {_, _ in },
                    onCancel: {})
}
