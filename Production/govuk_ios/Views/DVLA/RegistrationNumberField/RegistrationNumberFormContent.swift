import SwiftUI

/// The registration number entry form: label, input field, and cancel/submit buttons. Presentation-agnostic.
struct RegistrationNumberFormContent: View {
    @ObservedObject var viewModel: RegistrationNumberFormViewModel
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            StateLabel(content: labelContent)
                .font(.system(size: 18, weight: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 12)

            RegistrationNumberField(
                text: $viewModel.numberPlate,
                maxCharacters: viewModel.maxCharacters
            )
            .focused($isFieldFocused)
            .padding(.bottom, 12)
            .padding(.trailing, 8)

            actionButtons
                .padding(.bottom, 16)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8),
                   value: viewModel.isValidPlate)
        .padding(.horizontal, 16)
        .onAppear { isFieldFocused = true }
    }
}

extension RegistrationNumberFormContent {
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button("Cancel", action: viewModel.cancel)
                .buttonStyle(RegistrationCancelButtonStyle())

            if viewModel.isValidPlate {
                Button(action: viewModel.submit) {
                    Text("Submit")
                }
                .buttonStyle(LoadingButtonStyle(
                    isLoading: viewModel.isLoading,
                    loadingLabel: viewModel.loadingLabel
                ))
                .disabled(!viewModel.isValidPlate || viewModel.isLoading)
                .transition(.opacity.combined(with:
                        .move(edge: .trailing))
                )
            }
        }
    }

    private var labelContent: StateLabelContent {
        if let error = viewModel.error {
            return .error(error.rawValue)
        }

        // suppress the format error while the user is actively typing
        if isFieldFocused
            || viewModel.numberPlate.isEmpty
            || viewModel.isValidPlate {
            return .normal(String(
                    localized: .DVLA.enterNumberPlateLabel
                )
            )
        }

        return .error(String(localized: .DVLA.plateMustBe2To7Characters))
    }
}
