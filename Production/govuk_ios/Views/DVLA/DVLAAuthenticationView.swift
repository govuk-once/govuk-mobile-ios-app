import GovKit
import SwiftUI

struct DVLAAuthenticationView: View {
    @StateObject private var viewModel: DVLAAuthenticationViewModel

    init(viewModel: DVLAAuthenticationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color(UIColor.govUK.fills.surfaceFullScreenLinkAccount)
                .ignoresSafeArea()
            loadingView
        }
        .ignoresSafeArea(edges: .vertical)
        .navigationBarHidden(true)
        .task {
            await viewModel.refreshToken()
        }
    }

    private var loadingView: some View {
        VStack {
            ProgressView()
                .controlSize(.large)
                .tint(Color(UIColor.govUK.text.header))
                .accessibilityLabel(.DVLA.loadingAccessibilityLabel)
        }
    }
}
