import SwiftUI
import Foundation
import GovKitUI

struct UnsetLocalWasteWidgetView: View {
    private var viewModel: UnsetLocalWasteWidgetViewModel

    init(viewModel: UnsetLocalWasteWidgetViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderLabelView(
                model: SectionHeaderLabelViewModel(
                    title: viewModel.title,
                )
            )
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.widgetTitle)
                    .title3SemiboldPrimary()
                    .maxWidthMultilineLeading()
                Spacer().frame(height: 8)
                Text(viewModel.widgetDescription)
                    .bodyPrimary()
                    .maxWidthMultilineLeading()
                Spacer().frame(height: 16)
                SwiftUIButton(
                    .primary,
                    viewModel: viewModel.primaryButtonViewModel
                )
                .frame(minHeight: 44, idealHeight: 44)
            }
            .padding(16)
            .background {
                Color(uiColor: UIColor.govUK.fills.surfaceList)
            }
            .roundedBorder(borderColor: .clear)
            .shadow(
                color: Color(
                    uiColor: UIColor.govUK.strokes.cardDefault
                ), radius: 0, x: 0, y: 3
            )
        }
    }
}
