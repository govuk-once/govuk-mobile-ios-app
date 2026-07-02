import GovKit
import SwiftUI
import GovKitUI

struct ServiceAccountLinkSuccessView: View {
    private let outerPadding: CGFloat = 16.0
    @StateObject private var viewModel: ServiceAccountLinkSuccessViewModel

    init(viewModel: ServiceAccountLinkSuccessViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ViewThatFits(in: .vertical) {
            VStack(spacing: 24) {
                imageView
                titleView
            }
            titleView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(outerPadding)
        .safeAreaInset(edge: .bottom) {
            primaryButtonView
                .background(Color(UIColor.govUK.fills.surfaceFullScreenLinkAccount))
        }
        .background(Color(UIColor.govUK.fills.surfaceFullScreenLinkAccount))
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
    }

    private var titleView: some View {
        Text(viewModel.title)
            .font(.govUK.largeTitleBold)
            .foregroundStyle(Color(UIColor.govUK.text.header))
            .multilineTextAlignment(.center)
    }

    private var imageView: some View {
        Image(systemName: "checkmark.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 95, height: 95)
            .foregroundStyle(Color(UIColor.govUK.text.header))
            .accessibilityHidden(true)
    }

    private var primaryButtonView: some View {
        SwiftUIButton(
            viewModel.primaryButtonConfiguration,
            viewModel: viewModel.primaryButtonViewModel
        )
        .frame(minHeight: 44, idealHeight: 44)
        .padding(outerPadding)
    }
}

extension ServiceAccountLinkSuccessView: TrackableScreen {
    var trackingName: String {
        viewModel.trackingName
    }
    var trackingTitle: String? {
        viewModel.trackingTitle
    }
}
