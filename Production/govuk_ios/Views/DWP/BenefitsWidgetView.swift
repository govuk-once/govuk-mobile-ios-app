import SwiftUI

struct BenefitsWidgetView: View {
    @StateObject var viewModel: BenefitsWidgetViewModel

    var body: some View {
        VStack {
            accountView
        }.onAppear {
            viewModel.fetchedBenefitsData()
        }
    }
    @ViewBuilder
    private var accountView: some View {
        switch viewModel.state {
        case .loading:
            loadingView
        case .unlinked(let linkCardViewModel):
            makeLinkCardView(for: linkCardViewModel)
        }
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

    private func makeLinkCardView(for viewModel: ServiceAccountLinkCardViewModel) -> some View {
        ServiceAccountLinkCardView(viewModel: viewModel)
            .padding(.horizontal, 16)
    }
}
