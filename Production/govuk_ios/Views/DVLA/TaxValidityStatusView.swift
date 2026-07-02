import SwiftUI
import GovKitUI

struct TaxValidityStatusView: View {
    private static let standardPadding: CGFloat = 16.0
    private static let largeIconSize: CGFloat = 44

    let viewModel: ValidityStatusViewModel

    var body: some View {
        switch viewModel.status as? ValidityTaxStatus {
        case .sorn, .futureSorn:
            sornView
                .padding(Self.standardPadding)
        default:
            ValidityStatusView(viewModel: viewModel)
        }
    }
}

extension TaxValidityStatusView {
    var sornView: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: viewModel.iconName ?? "")
                .foregroundStyle(Color(
                    uiColor: viewModel.iconTintColour ?? .govUK.Text.primary
                ))
                .font(.govUK.title1)
                .frame(
                    minWidth: Self.largeIconSize,
                    minHeight: Self.largeIconSize
                )
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(viewModel.formattedStatus)
                    .font(.govUK.bodySemibold)
                    .multilineTextAlignment(.leading)
                if let footer = viewModel.footer {
                    Text(footer)
                        .font(.govUK.body)
                        .foregroundStyle(Color(uiColor: .govUK.text.primary))
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }
            }
            Spacer()
        }
    }
}
