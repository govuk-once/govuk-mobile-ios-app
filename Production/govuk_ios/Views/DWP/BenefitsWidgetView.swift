import SwiftUI

struct BenefitsWidgetView: View {
    let viewModel: BenefitsWidgetViewModel

    init(viewModel: BenefitsWidgetViewModel) {
        self.viewModel = viewModel
    }
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
            ProgressView()
        case .unlinked(let linkCardViewModel):
            makeLinkCardView(for: linkCardViewModel)
        }
    }

    private func makeLinkCardView(for viewModel: ServiceAccountLinkCardViewModel) -> some View {
        ServiceAccountLinkCardView(viewModel: viewModel)
            .padding(.horizontal, 16)
    }
}
