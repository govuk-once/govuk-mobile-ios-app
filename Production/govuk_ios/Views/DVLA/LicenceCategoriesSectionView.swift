import SwiftUI
import GovKit

struct LicenceCategoriesSectionViewModel {
    let listContent: [GroupedListSection]

    init(action: @escaping (String) -> Void) {
        let buttonTitle = String(localized: .DVLA.licenceCategoriesButtonTitle)
        let categoriesRow = NavigationRow(
            id: UUID().uuidString,
            title: buttonTitle,
            body: nil,
            action: {
                action(buttonTitle)
            }
        )
        listContent = [
            GroupedListSection(
                heading: nil,
                rows: [categoriesRow],
                footer: nil
            )
        ]
    }
}

struct LicenceCategoriesSectionView: View {
    let viewModel: LicenceCategoriesSectionViewModel
    var body: some View {
        VStack(spacing: 8) {
            Text(.DVLA.licenceCategoriesTitle)
                .font(.govUK.title2.bold())
                .foregroundColor(Color(UIColor.govUK.text.primary))
                .accessibilityAddTraits(.isHeader)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(.DVLA.licenceCategoriesSubtitle)
                .font(.govUK.subheadline)
                .foregroundColor(Color(UIColor.govUK.text.primary))
                .frame(maxWidth: .infinity, alignment: .leading)
            GroupedList(content: viewModel.listContent)
                .padding(.top, 8)
        }
    }
}

#Preview {
    let viewModel = LicenceCategoriesSectionViewModel(
        action: { buttonTitle in
            print(buttonTitle)
        }
    )
    ZStack {
        Color(uiColor: .govUK.fills.surfaceBackground)
        LicenceCategoriesSectionView(viewModel: viewModel)
    }
}
