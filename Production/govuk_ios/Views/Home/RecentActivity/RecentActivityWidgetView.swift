import SwiftUI
import GovKitUI
import GovKit

struct RecentActivityWidgetView: View {
    @ObservedObject var viewModel: RecentActivityHomepageWidgetViewModel

    var body: some View {
        if viewModel.sections.isEmpty {
            emptyStateView
        } else {
            VStack(
                alignment: .leading,
                spacing: 16,
                content: {
                    SectionHeaderLabelView(
                        model: SectionHeaderLabelViewModel(
                        title: viewModel.title,
                        button: .init(
                            localisedTitle: viewModel.seeAllButtonTitle,
                            action: { viewModel.seeAllAction() }
                        )
                    )
                )
                    GroupedList(
                        content: viewModel.sections
                    )
                }
            )
        }
    }
    private var emptyStateView: some View {
        VStack(
            alignment: .leading,
            spacing: 16,
            content: {
                SectionHeaderLabelView(
                    model: .init(
                        title: viewModel.title
                    )
                )
                NonTappableCardView(
                    text: viewModel.emptyActivityStateTitle
                )
            }
        )
    }
}
