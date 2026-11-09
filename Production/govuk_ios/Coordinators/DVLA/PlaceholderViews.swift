import SwiftUI

final class KKVehicleCheckViewModel: ObservableObject {
    /// A closure invoked by the ViewModel to request pushing a new SwiftUI view onto the coordinator's navigation stack.
    var onPushView: ((any View) -> Void)?

    func handleNextTapped() {
        // Perform any business logic or state changes here, then trigger the navigation push
        let detailView = KKVehicleCheckDetailView()
        onPushView?(detailView)
    }
}

struct KKVehicleCheckDetailView: View {
    var body: some View {
        Text("Vehicle CheccckDDDEEEtail")
    }
}

struct KKVehicleCheckRootView: View {
    @ObservedObject var viewModel: KKVehicleCheckViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Vehicle Check")
                .font(.title2)
                .fontWeight(.bold)

            Text("Begin your vehicle inspection process below.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button(action:
                viewModel.handleNextTapped
            ) {
                Text("Next Step")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .navigationTitle("Inspection")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct KKVehicleCheckRootViewNoViewModel: View {
    let onTapNext: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Vehicle Check")
                .font(.title2)
                .fontWeight(.bold)

            Text("Begin your vehicle inspection process below.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button(action: onTapNext) {
                Text("Next Step")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .navigationTitle("Inspection")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("KKVehicleCheckRootViewNoViewModel") {
    NavigationStack {
        KKVehicleCheckRootViewNoViewModel(onTapNext: { /* no op */ })
    }
}

#Preview("KKVehicleCheckDetailView") {
    KKVehicleCheckDetailView()
}
