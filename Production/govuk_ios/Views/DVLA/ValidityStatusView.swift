import SwiftUI
import GovKitUI

struct ValidityStatusView: View {
    private static let iconSize: CGFloat = 36
    private static let standardPadding: CGFloat = 16.0

    let viewModel: ValidityStatusViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                if let title = viewModel.title {
                    Text(title)
                        .font(.govUK.title3Semibold)
                        .multilineTextAlignment(.leading)
                }
                Text("\(viewModel.status)")
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color(uiColor: .govUK.fills.surfaceButtonPrimary))
                .font(.govUK.title2)
                .frame(
                    width: Self.iconSize,
                    height: Self.iconSize
                )
                .accessibilityHidden(true)
        }
        .padding(Self.standardPadding)
    }
}
