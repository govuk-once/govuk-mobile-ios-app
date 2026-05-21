import SwiftUI
import GovKit
import GovKitUI
import Lottie

struct ErrorView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @StateObject private var viewModel: ErrorViewModel

    init(viewModel: ErrorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    if verticalSizeClass != .compact {
                        imageView
                            .accessibilityHidden(true)
                    }
                    Text(viewModel.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(UIColor.govUK.text.primary))
                        .font(.govUK.largeTitleBold)
                        .multilineTextAlignment(viewModel.textAlignment)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.top, topPadding)
                        .padding(.bottom, 16)
                        .frame(
                            maxWidth: .infinity,
                            alignment: viewModel.contentAlignment
                        )
                    Text(LocalizedStringKey(viewModel.subtitle))
                        .foregroundColor(Color(UIColor.govUK.text.primary))
                        .font(.govUK.body)
                        .multilineTextAlignment(viewModel.textAlignment)
                        .frame(
                            maxWidth: .infinity,
                            alignment: viewModel.contentAlignment
                        )
                }
                .padding(.horizontal, 16)
                .frame(width: geometry.size.width)
                .frame(
                    minHeight: geometry.size.height,
                    alignment: viewModel.contentAlignment
                )
            }
        }
        .navigationBarHidden(true)
        .background(Color(uiColor: UIColor.govUK.fills.surfaceFullscreen))
        .safeAreaInset(edge: .bottom) {
            buttonView
                .background(Color(uiColor: UIColor.govUK.fills.surfaceFullscreen))
        }
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
    }

    @ViewBuilder
    private var imageView: some View {
        if let imageName = viewModel.systemImageName {
            Image(systemName: imageName)
                .font(.system(size: 107, weight: .light))
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private var buttonView: some View {
        if let secondaryButtonViewModel = viewModel.secondaryButtonViewModel {
            ButtonStackView(
                primaryButtonViewModel: viewModel.primaryButtonViewModel,
                secondaryButtonViewModel: secondaryButtonViewModel
            )
        } else if viewModel.showPrimaryButton {
            VStack {
                Divider()
                    .overlay(Color(UIColor.govUK.strokes.fixedContainer))
                SwiftUIButton(
                    .primary,
                    viewModel: viewModel.primaryButtonViewModel
                )
                .frame(minHeight: 44, idealHeight: 44)
                .padding(16)
            }
        }
    }

    private var topPadding: CGFloat {
        if viewModel.contentAlignment == .center {
            return 0
        } else {
            return verticalSizeClass == .compact ? 30 : 46
        }
    }
}

extension ErrorView: TrackableScreen {
    var trackingName: String {
        viewModel.trackingName
    }

    var trackingTitle: String? {
        viewModel.trackingTitle
    }
}
