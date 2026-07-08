import SwiftUI
import GovKit

struct ExpiryProgressView: View {
    let viewModel: ExpiryProgressViewModel

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let dotSize: CGFloat = 12
                let spacing: CGFloat = 4
                let totalSpacing = spacing * 2
                let availableWidth = geometry.size.width - dotSize - totalSpacing
                HStack(spacing: spacing) {
                    Capsule()
                        .fill(Color(uiColor: .accentPurple))
                        .frame(width: max(0, availableWidth * viewModel.progress))
                    Circle()
                        .fill(Color(uiColor: .govUK.text.primary))
                        .frame(width: dotSize, height: dotSize)
                    Capsule()
                        .fill(Color(uiColor: .govUK.fills.surfaceBackground))
                        .frame(width: max(0, availableWidth * (1 - viewModel.progress)))
                }
                .frame(height: 12)
            }
            .padding(.top, 15)
            .padding(.bottom, 8)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityHidden(true)
            Text(viewModel.footer)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.govUK.callout)
                .foregroundStyle(Color(uiColor: .govUK.text.primary))
        }
    }
}
