import SwiftUI
import GovKit
import GovKitUI

struct DrivingLicenceView: View {
    @StateObject private var viewModel: DrivingLicenceViewModel

    init(viewModel: DrivingLicenceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .loaded(let licenceSummaryViewModel):
                makeLicenceView(for: licenceSummaryViewModel)
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
                .accessibilityLabel(String.dvla.localized("loadingLicenceAccessibilityLabel"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 86)
        }
        .background(Color(UIColor.govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }

    private func makeLicenceView(for licenceViewModel: DrivingLicenceSummaryViewModel)
    -> some View {
        DrivingLicenceSummaryView(viewModel: licenceViewModel)
            .background(Color(UIColor.govUK.fills.surfaceList))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
    }

    private func makeErrorView(for errorViewModel: InlineActionErrorViewModel) -> some View {
        InlineActionErrorView(viewModel: errorViewModel)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color(UIColor.govUK.fills.surfaceList))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
    }
}
