import SwiftUI

/// The plate entry form: label, input field, and cancel/submit buttons. Presentation-agnostic.
struct PlateFormContent: View {
    @ObservedObject var viewModel: PlateFormViewModel
    @FocusState private var isFieldFocused: Bool
    let onCancel: () -> Void
    let onSubmit: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            StateLabel(content: labelContent)
                .font(.system(size: 18, weight: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 12)

            DrivingLicenseField(
                text: $viewModel.numberPlate,
                maxCharacters: viewModel.maxCharacters
            )
            .focused($isFieldFocused)
            .padding(.bottom, 12)

            HStack(spacing: 8) {
                Button("Cancel") {
                    onCancel()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .cornerRadius(12)

                if viewModel.isValidPlate {
                    Button {
                        Task {
                            let plate = viewModel.numberPlate.trimmingCharacters(in: .whitespaces)
                            if await viewModel.submit() {
                                onSubmit(plate)
                            }
                        }
                    } label: {
                        Text("Submit")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(LoadingButtonStyle(isLoading: viewModel.isLoading))
                    .disabled(viewModel.isLoading)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .padding(.bottom, 16)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.isValidPlate)
        .padding(.horizontal, 16)
        .onAppear { isFieldFocused = true }
    }

    private var labelContent: StateLabelContent {
        if let error = viewModel.error {
            return .error(error.rawValue)
        } else if viewModel.numberPlate.isEmpty {
            return .normal("Enter number plate")
        } else if viewModel.isValidPlate {
            return .normal("Enter number plate")
        } else {
            return .error("Plate must be 2–7 characters")
        }
    }
}
