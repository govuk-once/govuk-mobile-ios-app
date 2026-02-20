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
            Button {
                viewModel.tapAction()
            } label: {
                VStack {
                    HStack(alignment: .center) {
                        Spacer()
                        VStack(alignment: .center) {
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundColor(
                                    Color(
                                        UIColor.govUK.text.iconTertiary
                                    )
                                )
                                .padding(.bottom, 6)
                                .font(.title)
                            Text(viewModel.description)
                                .multilineTextAlignment(.center)
                                .font(Font.govUK.body)
                                .foregroundColor(
                                    Color(UIColor.govUK.text.primary))
                                .padding(.horizontal)
                            Spacer()
                        }
                        .padding()
                        Spacer()
                    }
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
    }
}
