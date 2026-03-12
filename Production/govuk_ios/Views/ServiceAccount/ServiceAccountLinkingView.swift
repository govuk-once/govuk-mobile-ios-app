import GovKit
import SwiftUI

struct ServiceAccountLinkingView: View {
    @StateObject private var viewModel: ServiceAccountLinkingViewModel

    init(viewModel: ServiceAccountLinkingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            if let errorViewModel = viewModel.errorViewModel {
                errorView(with: errorViewModel)
            } else if viewModel.showProgressView {
                loadingView
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .toolbar {
            cancelButton
        }
        .task {
            viewModel.linkAccount()
        }
    }

    private var progressOpacity: CGFloat {
        viewModel.showProgressView ? 1.0 : 0.0
    }

    private var loadingView: some View {
        ZStack {
            Color(UIColor.govUK.fills.surfaceModal)
            ProgressView()
                .accessibilityLabel(viewModel.accessibilityLabel)
        }
        .opacity(progressOpacity)
        .animation(.easeOut.delay(viewModel.animationDelay),
                   value: progressOpacity)
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
