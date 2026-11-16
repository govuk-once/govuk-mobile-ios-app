import Foundation
import SwiftUI
import GovKitUI

struct StoredLocalAuthorityWidgetView: View {
    private let viewModel: StoredLocalAuthorityWidgetViewModel

    init(viewModel: StoredLocalAuthorityWidgetViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            headerSection
                .padding(.bottom, 8)
            if viewModel.localAuthorities.count == 1,
               let item = viewModel.cardModels().first {
                StoredLocalAuthorityCardView(model: item)
                    .onTapGesture {
                        viewModel.open(item: item)
                    }
            } else if viewModel.localAuthorities.count > 1 {
                HStack {
                    Text(viewModel.twoTierAuthorityDescription)
                        .font(.govUK.body)
                        .foregroundColor(Color(uiColor: UIColor.govUK.text.primary))
                        .padding(.bottom, 4)
                    Spacer()
                }
                twoTierView
            }
        }
    }

    @ViewBuilder
    var twoTierView: some View {
        ForEach(viewModel.cardModels(), id: \.name) { item in
            StoredLocalAuthorityCardView(model: item)
                .onTapGesture {
                    viewModel.open(item: item)
                }
                .padding(.bottom, 2)
        }
    }

    private var headerSection: some View {
        HStack {
            Text(viewModel.title)
                .font(Font.govUK.title3Semibold)
                .foregroundColor(
                    Color(
                        UIColor.govUK.text.primary
                    )
                )
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Menu {
                Button(
                    .LocalAuthority.changeLocalAuthorityMenuTitle,
                    action: viewModel.openEditViewAction
                )
                Button(
                    .LocalAuthority.removeLocalAuthorityMenuTitle,
                    role: .destructive,
                    action: viewModel.deleteAction
                )
            } label: {
                Text(viewModel.editButtonTitle)
                    .foregroundColor(
                        Color(UIColor.govUK.text.buttonSecondary)
                    )
                    .font(Font.govUK.subheadlineSemibold)
            }
            .accessibilityLabel(
                viewModel.editButtonAltText
            )
        }
    }
}
