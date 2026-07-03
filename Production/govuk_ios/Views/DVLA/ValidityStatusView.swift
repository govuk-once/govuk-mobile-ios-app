import SwiftUI
import GovKitUI

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
                    }
                    statusTextView
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
                    .primary,
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

    @ViewBuilder
    private var statusTextView: some View {
        if let statusAccessibilityLabel = viewModel.statusAccessibilityLabel {
            Text(viewModel.status)
                .multilineTextAlignment(.leading)
                .accessibilityLabel(statusAccessibilityLabel)
        } else {
            Text(viewModel.status)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    let viewModel = ValidityStatusViewModel(
        title: nil,
        status: "Expired 24 April 2026",
        iconName: "exclamationmark.triangle.fill",
        footer: "Your licence status may not update immediately when you renew it",
        buttonTitle: "Renew licence",
        buttonAction: { }
    )
    VStack(spacing: 0) {
        Color(uiColor: .govUK.fills.surfaceBackground)
        ValidityStatusView(viewModel: viewModel)
        Color(uiColor: .govUK.fills.surfaceBackground)
    }
}
