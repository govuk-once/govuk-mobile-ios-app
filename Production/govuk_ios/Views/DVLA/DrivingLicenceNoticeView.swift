import SwiftUI
import GovKit

/// Shared layout constants for `DrivingLicenceNoticeView` and `DrivingLicenceNoticeHeader`.
private enum Layout {
    static let horizontalPadding: CGFloat = 16
}

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
                .padding(.horizontal, Layout.horizontalPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let action = viewModel.action {
                let padding = (viewModel.titleStyle == .normal) ? Layout.horizontalPadding : 0
                    Divider()
                        .padding(.horizontal,
                                 padding)
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
                .padding(.horizontal, Layout.horizontalPadding)
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
        case .inverted:
            Color(uiColor: Self.revokedForeground)
        }
    }

    var backgroundColor: Color {
        switch style {
        case .normal:
            .clear
        case .inverted:
            Color(uiColor: Self.revokedBackground)
        }
    }

    var body: some View {
        Text(title)
            .font(.govUK.title1Bold)
            .foregroundStyle(foregroundColor)
            .padding(.top, 64)
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .accessibilityAddTraits(.isHeader)
        if style == .normal {
            Divider()
                .padding(.horizontal, Layout.horizontalPadding)
        }
    }
}

#if DEBUG
#Preview("Notice View - titleStyle normal") {
    DrivingLicenceNoticeView(
        viewModel: DrivingLicenceNoticeViewModel(
            title: "title",
            body: """
            body body
            multiline text
            the quick brown fox jumps over the lazy dog.
            Another line.
            """,
            action: nil
        )
    )
}

#Preview("Notice View - titleStyle revoked") {
    DrivingLicenceNoticeView(
        viewModel: DrivingLicenceNoticeViewModel(
            title: "title",
            titleStyle: .inverted,
            body: """
            body body
            multiline text
            the quick brown fox jumps over the lazy dog.
            Another line.
            """,
            action: nil
        )
    )
}

#Preview("Header") {
    VStack {
        DrivingLicenceNoticeHeader(
            title: "Normal Style",
            style: .normal
        )

        DrivingLicenceNoticeHeader(
            title: "Revoked Style",
            style: .inverted
        )
    }
}
#endif
