import SwiftUI
import GovKit
import GovKitUI

struct VehiclesView: View {
    @StateObject private var viewModel: VehiclesViewModel

    init(viewModel: VehiclesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .loaded(let vehicleViewModels):
                makeVehiclesView(for: vehicleViewModels)
            case .error(let errorViewModel):
                makeErrorView(for: errorViewModel)
            }
        }
        .task {
            await viewModel.viewDidAppear()
        }
    }

    private var loadingView: some View {
        ZStack {
            ProgressView()
                .accessibilityLabel(String.dvla.localized("loadingVehiclesAccessibilityLabel"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 86)
        }
        .background(Color(UIColor.govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }

    private func makeVehiclesView(for vehicleViewModels: [VehicleSummaryViewModel]) -> some View {
        LazyVStack {
            ForEach(vehicleViewModels) {
                VehicleSummaryView(viewModel: $0)
            }
            .background(Color(UIColor.govUK.fills.surfaceList))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.vertical, 6)
        }
        .padding(.horizontal, 16)
    }

    private func makeErrorView(for errorViewModel: AppErrorViewModel) -> some View {
        AppErrorView(viewModel: errorViewModel)
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(Color(UIColor.govUK.fills.surfaceList))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
    }
}
