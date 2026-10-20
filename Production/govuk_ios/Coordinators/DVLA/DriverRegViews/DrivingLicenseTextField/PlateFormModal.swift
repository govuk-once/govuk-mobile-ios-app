import SwiftUI

struct PlateFormModal: View {
    let viewModel: PlateFormViewModel
    let onCancel: () -> Void
    let onSubmit: (String) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack {
                Spacer()
                PlateFormContent(
                    viewModel: viewModel,
                    onCancel: onCancel,
                    onSubmit: onSubmit
                )
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 5)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
}
