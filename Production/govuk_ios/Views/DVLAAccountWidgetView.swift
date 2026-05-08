import SwiftUI
import GovKit

struct DVLAAccountWidgetView: View {
    @StateObject private var viewModel: DVLAAccountWidgetViewModel

    init(viewModel: DVLAAccountWidgetViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if let errorViewModel = viewModel.errorViewModel {
                errorView(for: errorViewModel)
            } else if viewModel.isLoading {
                loadingView
            } else if let linkCardViewModel = viewModel.linkCardViewModel {
                linkCardView(for: linkCardViewModel)
            } else {
                listView
            }
        }
        .task {
            await viewModel.viewDidAppear()
        }
    }

    private func errorView(for errorViewModel: AppErrorViewModel) -> some View {
        AppErrorView(viewModel: errorViewModel)
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(Color(UIColor.govUK.fills.surfaceList))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
    }

    private var listView: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.actionCards) { cardModel in
                ListCardView(viewModel: cardModel)
            }
        }
        .padding(.bottom, 8)
        .padding(.horizontal, 16)
        .background(Color(UIColor.govUK.fills.surfaceBackground))
    }

    private func linkCardView(for linkCardViewModel: ServiceAccountLinkCardViewModel) -> some View {
        ServiceAccountLinkCardView(viewModel: linkCardViewModel)
            .padding(.horizontal, 16)
    }

    private var loadingView: some View {
        ZStack {
            ProgressView()
                .accessibilityLabel(String.topics.localized("loading"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
        }
        .background(Color(UIColor.govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }
}
