import SwiftUI
import GovKitUI

struct MotValidityStatusView: View {
    private static let standardPadding: CGFloat = 16.0
    let viewModel: ValidityStatusViewModel

    var body: some View {
        switch viewModel.status as? MOTValidityStatus {
        case .expired, .expiringSoon, .unknown, .valid, .none:
            ValidityStatusView(viewModel: viewModel)
        case .noResultsReturned, .noDetailsHeldByDVLA:
            VStack {
                HStack {
                    Text(viewModel.title ?? "")
                        .font(Font.govUK.bodySemibold)
                        .foregroundColor(
                            Color(UIColor.govUK.text.primary)
                        )
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 2)
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
                        .padding(
                            .horizontal,
                            Self.standardPadding
                        )
                    }
                )
            }
            .padding(.vertical, 8)
        }
    }
}
