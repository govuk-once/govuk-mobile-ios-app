import SwiftUI
import GovKit

struct DrivingLicenceNoticeView: View {
    let viewModel: DrivingLicenceNoticeViewModel
    var body: some View {
        VStack(spacing: 0) {
            Text(viewModel.title)
                .font(.govUK.title1Bold)
                .foregroundStyle(Color(uiColor: .govUK.text.primary))
                .padding(.top, 64)
                .padding([.horizontal, .bottom], 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
            Divider()
            Text(viewModel.body)
                .font(.govUK.body)
                .foregroundStyle(Color(uiColor: .govUK.text.primary))
                .padding(.vertical, 24)
                .padding(.leading, 16)
                .padding(.trailing, 60)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let action = viewModel.action {
                Divider()
                button(for: action)
            }
        }
    }

    private func button(for action: DrivingLicenceNoticeViewModel.Action) -> some View {
        Button(
            action: action.handler,
            label: {
                HStack {
                    Text(action.buttonTitle)
                        .font(.govUK.body)
                        .foregroundStyle(Color(uiColor: .govUK.text.link))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .font(.govUK.body)
                        .foregroundStyle(Color(uiColor: .govUK.text.link))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
        )
    }
}
