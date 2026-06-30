import SwiftUI
import GovKitUI

struct TaxValidityStatusView: View {
    private static let standardPadding: CGFloat = 16.0
    private static let iconSize: CGFloat = 36
    private static let largeIconSize: CGFloat = 44

    let viewModel: ValidityStatusViewModel

    var body: some View {
        switch viewModel.status as? TaxStatus {
        case .taxed:
            ValidityStatusView(viewModel: viewModel)
        case .untaxed:
            untaxedView
                .padding(Self.standardPadding)
        case .sorn:
            sornView
                .padding(Self.standardPadding)
        default:
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.title ?? "")
                        .font(.govUK.title3Semibold)
                        .multilineTextAlignment(.leading)
                    Text(viewModel.formattedStatus)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding(Self.standardPadding)
        }
    }
}

extension TaxValidityStatusView {
    var untaxedView: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.title ?? "")
                        .font(.govUK.title3Semibold)
                        .multilineTextAlignment(.leading)
                    Text(viewModel.formattedStatus)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: viewModel.iconName ?? "")
                    .foregroundStyle(Color(
                        uiColor: viewModel.iconTintColour ?? .govUK.Text.primary
                    ))
                    .font(.govUK.title2)
                    .frame(
                        width: Self.iconSize,
                        height: Self.iconSize
                    )
                    .accessibilityHidden(true)
            }
            if let buttonViewModel = viewModel.buttonViewModel {
                SwiftUIButton(
                    .primary,
                    viewModel: buttonViewModel
                )
            }
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
                Text(viewModel.footer ?? "")
                    .font(.govUK.body)
                    .foregroundStyle(Color(uiColor: .govUK.text.primary))
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }
            Spacer()
        }
    }
}
