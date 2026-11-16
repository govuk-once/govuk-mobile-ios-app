import Foundation
import SwiftUI
import GovKitUI

struct StoredLocalAuthorityWidgetView: View {
    private let viewModel: StoredLocalAuthorityWidgetViewModel
    @State var alertPresented = false

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
        .alert(
            String(localized: .LocalAuthority.removeLocalAuthorityAlertTitle),
            isPresented: $alertPresented,
            presenting: alertPresented
        ) { _ in
            Button(
                .LocalAuthority.removeLocalAuthorityButtonTitle,
                role: .destructive,
                action: viewModel.deleteAction
            )
        } message: { _ in
            Text(String(localized: .LocalAuthority.removeLocalAuthorityAlertDescription))
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
                    .LocalAuthority.changeLocalAuthorityButtonTitle,
                    action: viewModel.openEditViewAction
                )
                .accessibilityLabel(.LocalAuthority.changeLocalAuthorityAccessibilityLabel)
                Button(
                    .LocalAuthority.removeLocalAuthorityButtonTitle,
                    role: .destructive,
                    action: { alertPresented = true }
                )
                .accessibilityLabel(.LocalAuthority.removeLocalAuthorityAccessibilityLabel)
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
