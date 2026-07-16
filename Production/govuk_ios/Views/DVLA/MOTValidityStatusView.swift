import SwiftUI
import GovKitUI

struct MotValidityStatusView: View {
    private static let iconSize: CGFloat = 36
    private static let standardPadding: CGFloat = 16.0

    let viewModel: ValidityStatusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.title != nil || !viewModel.formattedStatus.isEmpty
                || viewModel.iconName != nil {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        if let title = viewModel.title {
                            Text(title)
                                .font(.govUK.title3Semibold)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.primary)
                        }
                        statusTextView
                    }
                    Spacer()
                    if let iconName = viewModel.iconName {
                        Image(systemName: iconName)
                            .foregroundStyle(
                                Color(
                                    uiColor: viewModel.iconTintColour ?? .govUK.Text.primary
                                )
                            )
                            .font(.govUK.title2)
                            .frame(width: Self.iconSize, height: Self.iconSize)
                            .accessibilityHidden(true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Self.standardPadding)
                .padding(.top, Self.standardPadding)
                .padding(.bottom,
                         viewModel.progressViewModel
                         != nil ? 12 :
                            (viewModel.buttonViewModel != nil ? 0 : Self.standardPadding))
            }
            if let progressViewModel = viewModel.progressViewModel {
                ExpiryProgressView(viewModel: progressViewModel)
                    .padding(.horizontal, Self.standardPadding)
                    .padding(.bottom,
                             (viewModel.buttonViewModel == nil
                              && viewModel.footer == nil) ? Self.standardPadding : 0)
            }
            if viewModel.buttonViewModel != nil {
                if !viewModel.formattedStatus.isEmpty {
                    Divider()
                        .background(Color(uiColor: .separator))
                }

                Button(
                    action: { },
                    label: {
                        HStack(alignment: .center) {
                            Text(viewModel.buttonTitle ?? "")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(red: 0.15, green: 0.35, blue: 0.75))

                            Spacer()

                            Image(systemName: "arrow.up.forward")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.15, green: 0.35, blue: 0.75))
                        }
                        .padding(.horizontal, Self.standardPadding)
                        .padding(.vertical, 16)
                    }
                )
                .frame(maxWidth: .infinity)
                .padding(.top, viewModel.formattedStatus.isEmpty ? -24 : 0)
            }

            if let footer = viewModel.footer {
                Text(footer)
                    .font(.govUK.footnote)
                    .foregroundStyle(Color(uiColor: .govUK.text.secondary))
                    .padding(.horizontal, Self.standardPadding)
                    .padding(.bottom, Self.standardPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(uiColor: .systemBackground))
    }

    @ViewBuilder
    private var statusTextView: some View {
        if let statusAccessibilityLabel = viewModel.statusAccessibilityLabel {
            Text(viewModel.formattedStatus)
                .multilineTextAlignment(.leading)
                .accessibilityLabel(statusAccessibilityLabel)
        } else if !viewModel.formattedStatus.isEmpty {
            Text(viewModel.formattedStatus)
                .multilineTextAlignment(.leading)
        }
    }
}
