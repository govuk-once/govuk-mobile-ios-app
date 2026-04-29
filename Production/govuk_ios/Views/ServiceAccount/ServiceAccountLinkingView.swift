import GovKit
import SwiftUI

struct ServiceAccountLinkingView: View {
    @StateObject private var viewModel: ServiceAccountLinkingViewModel

    init(viewModel: ServiceAccountLinkingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if let errorViewModel = viewModel.errorViewModel {
                errorView(with: errorViewModel)
            } else {
                ZStack {
                    Color(UIColor.govUK.fills.surfaceFullScreenLinkAccount)
                        .ignoresSafeArea()
                    loadingView
                }
                .ignoresSafeArea(edges: .vertical)
            }
        }
        .task {
            viewModel.linkAccount()
        }
    }

    private var progressOpacity: CGFloat {
        viewModel.showProgressView ? 1.0 : 0.0
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
                .tint(Color(UIColor.govUK.text.header))
                .accessibilityHidden(true)
            Text(viewModel.title)
                .font(Font.govUK.largeTitleBold)
                .foregroundStyle(Color(UIColor.govUK.text.header))
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .opacity(progressOpacity)
    }

    private func errorView(with errorViewModel: AppErrorViewModel) -> some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Spacer()
                    AppErrorView(viewModel: errorViewModel)
                    Spacer()
                }
                .frame(minHeight: geometry.size.height)
                .frame(width: geometry.size.width)
            }
            .background(Color(UIColor.govUK.fills.surfaceModal))
            .toolbar {
                cancelButton
            }
        }
    }

    private var cancelButton: some ToolbarContent {
        ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
            Button(
                action: {
                    viewModel.dismiss()
                }, label: {
                    Text(String.common.localized("cancel"))
                        .foregroundColor(
                            Color(UIColor.govUK.text.linkSecondary)
                        )
                        .font(Font.govUK.subheadlineSemibold)
                }
            )
        }
    }
}
