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
                    VStack(alignment: .leading, spacing: 8) {
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
                         viewModel.progressViewModel != nil ? 0 :
                            (
                                viewModel.buttonViewModel != nil
                                && viewModel.formattedStatus.isEmpty
                                ? 0 : Self.standardPadding))
            }
            if let progressViewModel = viewModel.progressViewModel {
                ExpiryProgressView(viewModel: progressViewModel)
                    .padding(
                        .horizontal,
                        Self.standardPadding
                    )
                    .padding(
                        .bottom,
                        (viewModel.buttonViewModel == nil
                         && viewModel.footer == nil)
                        ? Self.standardPadding : 4)
            }

            if viewModel.buttonViewModel != nil {
                if !viewModel.formattedStatus.isEmpty {
                    Divider()
                        .background(Color(uiColor: .separator))
                        .padding(.top, 4)
                }
                Button(
                    action: {
                        viewModel.buttonAction?()
                    },
                    label: {
                        HStack(alignment: .center) {
                            Text(viewModel.buttonTitle ?? "")
                                .font(Font.govUK.body)
                                .foregroundColor(
                                    Color(UIColor.govUK.text.linkSecondary)
                                )
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .foregroundColor(
                                Color(UIColor.govUK.text.linkSecondary)
                                )
                                .font(Font.govUK.bodySemibold)
                        }
                        .padding(.horizontal, Self.standardPadding)
                        .padding(.vertical, viewModel.formattedStatus.isEmpty ? 10 : 16)
                    }
                )
                .frame(maxWidth: .infinity)
                .padding(.top, viewModel.formattedStatus.isEmpty ? -4 : 0)
            }

            if let footer = viewModel.footer {
                Text(footer)
                    .font(.govUK.footnote)
                    .foregroundStyle(Color(uiColor: .govUK.text.secondary))
                    .padding(.horizontal, Self.standardPadding)
                    .padding(.top, 8)
                    .padding(.bottom, Self.standardPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private var statusTextView: some View {
        if let statusAccessibilityLabel
            = viewModel.statusAccessibilityLabel, !viewModel.formattedStatus.isEmpty {
            Text(viewModel.formattedStatus)
                .multilineTextAlignment(.leading)
                .accessibilityLabel(statusAccessibilityLabel)
                .fixedSize(horizontal: false, vertical: true)
        } else if !viewModel.formattedStatus.isEmpty {
            Text(viewModel.formattedStatus)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
