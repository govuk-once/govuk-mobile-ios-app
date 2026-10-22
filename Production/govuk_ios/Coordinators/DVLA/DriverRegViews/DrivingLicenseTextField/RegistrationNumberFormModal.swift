import SwiftUI

struct RegistrationNumberFormModal: View {
    let viewModel: RegistrationNumberFormViewModel
    let onCancel: () -> Void
    let onSubmit: (VehicleEnquiryResponse.Vehicle) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack {
                Spacer()
                RegistrationNumberFormContent(
                    viewModel: viewModel,
                    cancelAction: onCancel,
                    submitAction: onSubmit
                )
                .background(Color(uiColor: .govUK.fills.registrationFormBackgroundColor))
                .cornerRadius(33)
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 5)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
    }
}
