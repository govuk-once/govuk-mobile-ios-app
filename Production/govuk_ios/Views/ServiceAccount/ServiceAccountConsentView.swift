import GovKit
import SwiftUI
import GovKitUI

struct ServiceAccountConsentView: View {
    private let outerPadding: CGFloat = 16.0
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var scrollViewContentHeight: CGFloat = 0
    @State private var scrollViewContainerHeight: CGFloat = 0
    @StateObject private var viewModel: ServiceAccountConsentViewModel

    init(viewModel: ServiceAccountConsentViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            contentView
        }
        .modifier(ScrollBounceBehaviorModifier())
        .onGeometryChange(
            for: CGFloat.self,
            of: {
                $0.size.height
            },
            action: {
                scrollViewContainerHeight = $0
            }
        )
        .safeAreaInset(edge: .bottom) {
            VStack {
                if shouldShowDivider {
                    Divider()
                        .overlay(Color(UIColor.govUK.strokes.linkAccountDivider))
                }
                primaryButtonView
            }
            .background(Color(UIColor.govUK.fills.surfaceFullScreenLinkAccount))
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                closeButton
            }
        }
        .toolbarBackground(
            Color(UIColor.govUK.fills.surfaceFullScreenLinkAccount),
            for: .navigationBar
        )
        .background(Color(UIColor.govUK.fills.surfaceFullScreenLinkAccount))
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
    }

    private var contentView: some View {
        VStack(alignment: .leading) {
            Text(viewModel.title)
                .font(titleFont)
                .foregroundStyle(Color(UIColor.govUK.text.header))
                .multilineTextAlignment(.leading)
                .accessibilityAddTraits(.isHeader)
                .padding([.top], titleTopPadding)
            Text(viewModel.descriptionTop)
                .font(descriptionFont)
                .foregroundStyle(Color(UIColor.govUK.text.header))
                .multilineTextAlignment(.leading)
                .padding([.top], 24)
            Text(viewModel.descriptionBottom)
                .font(descriptionFont)
                .foregroundStyle(Color(UIColor.govUK.text.header))
                .multilineTextAlignment(.leading)
                .padding([.top], 16)
            Spacer(minLength: outerPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(outerPadding)
        .onGeometryChange(
            for: CGFloat.self,
            of: {
                $0.size.height
            },
            action: {
                scrollViewContentHeight = $0
            }
        )
    }

    private var primaryButtonView: some View {
        SwiftUIButton(
            viewModel.primaryButtonConfiguration,
            viewModel: viewModel.primaryButtonViewModel
        )
        .frame(minHeight: 44, idealHeight: 44)
        .padding(outerPadding)
    }

    private var titleFont: Font {
        verticalSizeClass == .compact
        ? .govUK.title1Bold
        : .govUK.largeTitleBold
    }

    private var descriptionFont: Font {
        verticalSizeClass == .compact
        ? .govUK.title2
        : .govUK.title1
    }

    private var titleTopPadding: CGFloat {
        verticalSizeClass == .compact
        ? 30
        : 50
    }

    private var closeButton: some View {
        Button {
            viewModel.cancel()
        } label: {
            if #available(iOS 26.0, *) {
                closeButtonImage
            } else {
                closeButtonImage
                    .foregroundStyle(Color(UIColor.govUK.text.header))
                    .font(.system(size: 19, weight: .medium))
            }
        }
    }

    private var closeButtonImage: some View {
        Image(systemName: "xmark")
    }

    private var shouldShowDivider: Bool {
        scrollViewContentHeight > scrollViewContainerHeight
    }
}

extension ServiceAccountConsentView: TrackableScreen {
    var trackingName: String {
        viewModel.trackingName
    }
    var trackingTitle: String? {
        viewModel.trackingTitle
    }
    var additionalParameters: [String: Any] {
        ["format": "account bookend"]
    }
}
