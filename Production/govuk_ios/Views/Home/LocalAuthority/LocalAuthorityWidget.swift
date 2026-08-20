import SwiftUI
import Foundation
import GovKitUI

struct LocalAuthorityWidget: View {
    private var viewModel: LocalAuthorityWidgetViewModel

    init(viewModel: LocalAuthorityWidgetViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 16) {
            SectionHeaderLabelView(
                model: SectionHeaderLabelViewModel(
                    title: viewModel.title,
                )
            )

            IconActionCardView(
                viewModel: IconActionCardViewModel(
                    iconName: "plus.circle",
                    description: viewModel.description,
                    action: viewModel.tapAction
                )
            )
        }
    }
}
