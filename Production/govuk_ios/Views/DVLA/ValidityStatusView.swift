import SwiftUI
import GovKitUI

///
/// This view conditionally renders UI elements based on the values in `ValidityStatusViewModel`.
///
/// Optional values that are `nil` don't get displayed.
///
struct ValidityStatusView: View {
    private static let iconSize: CGFloat = 36
    private static let standardPadding: CGFloat = 16.0

    let viewModel: ValidityStatusViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    if let title = viewModel.title {
                        Text(title)
                            .font(.govUK.title3Semibold)
                            .multilineTextAlignment(.leading)
                            .accessibilityAddTraits(.isHeader)
                    }

                    if let statusInformation = viewModel.statusInformation {
                        StatusRowView(status: statusInformation)
                    }
                }
                Spacer()
                if let iconName = viewModel.iconName {
                    Image(systemName: iconName)
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
            }
            if let progressViewModel = viewModel.progressViewModel {
                ExpiryProgressView(viewModel: progressViewModel)
            }
            if let buttonViewModel = viewModel.buttonViewModel {
                SwiftUIButton(
                    viewModel.buttonConfiguration ?? .primary,
                    viewModel: buttonViewModel
                )
                .padding(.top, Self.standardPadding)
            }
            if let footer = viewModel.footer {
                Text(footer)
                    .font(.govUK.footnote)
                    .foregroundStyle(Color(uiColor: .govUK.text.secondary))
                    .padding(.top, Self.standardPadding)
                    .padding(.bottom, 8)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }
        }
        .padding(Self.standardPadding)
    }
}
