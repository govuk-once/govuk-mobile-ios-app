import SwiftUI

/// The registration number entry form: label, input field, and cancel/submit buttons. Presentation-agnostic.
struct RegistrationNumberFormContent: View {
    @ObservedObject var viewModel: RegistrationNumberFormViewModel
    @FocusState private var isFieldFocused: Bool
    let onCancel: () -> Void
    let onSubmit: (VehicleEnquiryResponse.Vehicle) -> Void

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

            HStack(spacing: 8) {
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(RegistrationCancelButtonStyle())

                if viewModel.isValidPlate {
                    Button {
                        handleSubmission()
                    } label: {
                        Text("Submit")
                    }
                    .buttonStyle(LoadingButtonStyle(
                        isLoading: viewModel.isLoading,
                        loadingLabel: viewModel.loadingLabel)
                    )
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
}

extension RegistrationNumberFormContent {

    private var labelContent: StateLabelContent {
        if let error = viewModel.error {
            return .error(error.rawValue)
        } else if viewModel.numberPlate.isEmpty {
            return .normal(
                String(localized: .DVLA.enterNumberPlateLabel)
            )
        } else if viewModel.isValidPlate {
            return .normal(
                String(localized: .DVLA.enterNumberPlateLabel)
            )
        } else {
            return .error(
                String(localized: .DVLA.plateMustBe2To7Characters)
            )

    private func handleSubmission() {
        Task {
            if await viewModel.submit(),
                let vehicle = viewModel.fetchedVehicle {
                onSubmit(vehicle)
            }
        }
    }
}
