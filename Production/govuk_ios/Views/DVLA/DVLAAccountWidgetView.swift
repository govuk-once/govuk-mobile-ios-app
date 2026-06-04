import SwiftUI
import GovKit

struct DVLAAccountWidgetView: View {
    @StateObject private var viewModel: DVLAAccountWidgetViewModel

    init(viewModel: DVLAAccountWidgetViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .linked(let actionCards, let accountSummaryViewModel):
                VStack {
                    makeAccountSummaryView(for: accountSummaryViewModel)
                    makeListView(for: actionCards)
                }
            case .unlinked(let linkCardViewModel):
                makeLinkCardView(for: linkCardViewModel)
            case .error(let errorViewModel):
                makeErrorView(for: errorViewModel)
            }
        }
        .task {
            await viewModel.viewDidAppear()
        }
    }

    private func makeErrorView(for errorViewModel: AppErrorViewModel) -> some View {
        AppErrorView(viewModel: errorViewModel)
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(Color(UIColor.govUK.fills.surfaceList))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
    }

    private func makeAccountSummaryView(for viewModel: DVLAAccountSummaryViewModel) -> some View {
        DVLAAccountSummaryView(viewModel: viewModel)
    }

    private func makeListView(for actionCards: [ListCardViewModel]) -> some View {
        VStack(spacing: 8) {
            ForEach(actionCards) { cardModel in
                ListCardView(viewModel: cardModel)
            }
        }
        .padding(.bottom, 8)
        .padding(.horizontal, 16)
        .background(Color(UIColor.govUK.fills.surfaceBackground))
    }

    private func makeLinkCardView(for viewModel: ServiceAccountLinkCardViewModel) -> some View {
        ServiceAccountLinkCardView(viewModel: viewModel)
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
