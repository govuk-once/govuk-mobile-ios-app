import SwiftUI
import GovKit

struct DrivingLicenceNoticeView: View {
    let viewModel: DrivingLicenceNoticeViewModel
    var body: some View {
        VStack(spacing: 0) {
            DrivingLicenceNoticeHeader(
                title: viewModel.title,
                style: viewModel.titleStyle
            )
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
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
        )
    }
}

struct DrivingLicenceNoticeHeader: View {
    let title: String
    let style: DrivingLicenceNoticeViewModel.TitleStyle

    static let revokedBackground: UIColor = {
        .init(
            light: .black,
            dark: .white
        )
    }()

    static let revokedForeground: UIColor = {
        .init(
            light: .white,
            dark: .black
        )
    }()

    var foregroundColor: Color {
        switch style {
        case .normal:
            Color(uiColor: .govUK.text.primary)
        case .revoked:
            Color(uiColor: Self.revokedForeground)
        }
    }

    var backgroundColor: Color {
        switch style {
        case .normal:
                .clear
        case .revoked:
            Color(uiColor: Self.revokedBackground)
        }
    }

    var body: some View {
        Text(title)
            .font(.govUK.title1Bold)
            .foregroundStyle(foregroundColor)
            .padding(.top, 64)
            .padding([.horizontal, .bottom], 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .accessibilityAddTraits(.isHeader)
        if style == .normal {
            Divider()
                .padding(.horizontal, 16)
        }
    }
}

#if DEBUG
#Preview("Notice View - titleStyle normal") {
    DrivingLicenceNoticeView(viewModel:
                                DrivingLicenceNoticeViewModel(
                                    title: "title",
                                    body: "body\nbody",
                                    action: nil)
                                )
}
#endif

#if DEBUG
#Preview("Notice View - titleStyle revoked") {
    DrivingLicenceNoticeView(viewModel:
                                DrivingLicenceNoticeViewModel(
                                    title: "title",
                                    titleStyle: .revoked,
                                    body: "body\nbody",
                                    action: nil)
                                )
}
#endif


#if DEBUG
#Preview("Header") {
    VStack {
        DrivingLicenceNoticeHeader(title: "Normal Style",
                                  style: .normal)

        DrivingLicenceNoticeHeader(title: "Revoked Style",
                                  style: .revoked)
    }
}
#endif
