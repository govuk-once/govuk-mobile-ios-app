import SwiftUI
import GovKit
import GovKitUI
import Lottie

struct InfoView<Model>: View where Model: InfoViewModelInterface {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @StateObject private var viewModel: Model
    private let customView: (() -> AnyView)?

    init(viewModel: Model,
         customView: (() -> AnyView)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.customView = customView
    }
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    infoView
                        .frame(width: geometry.size.width)
                        .frame(minHeight: geometry.size.height)
                }
                .modifier(ScrollBounceBehaviorModifier())
            }
            signInErrorText
            bottomContentText
            buttonView
        }
        .background(Color(uiColor: UIColor.govUK.fills.surfaceFullscreen))
        .overlay(content: {
            ZStack {
                Color(UIColor(light: .white, dark: .black))
                ProgressView()
                    .accessibilityLabel(loadingAccessibilityLabel)
            }
            .opacity(progressOpacity)
            .animation(.easeOut.delay(delay),
                       value: progressOpacity)
            .ignoresSafeArea()
        })
        .navigationBarHidden(viewModel.navBarHidden)
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
    }

    @ViewBuilder
    private var bottomContentText: some View {
        if let bottomContentText = viewModel.bottomContentText {
            Text(bottomContentText)
                .font(Font.govUK.caption1)
                .foregroundColor(Color(UIColor.govUK.text.secondary))
                .padding(.bottom, 16)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private var signInErrorText: some View {
        if let model = viewModel as? SignInErrorViewModel {
            HStack {
                Spacer()
                Text(model.errorCode)
                    .foregroundColor(Color(UIColor.govUK.text.primary.withAlphaComponent(0.5)))
                    .font(Font.govUK.caption2)
                    .accessibilityHidden(true)
                    .padding(.trailing, 16)
            }
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
            Divider()
                .overlay(Color(UIColor.govUK.strokes.fixedContainer))
            SwiftUIButton(
                viewModel.primaryButtonConfiguration,
                viewModel: viewModel.primaryButtonViewModel
            )
            .frame(minHeight: 44, idealHeight: 44)
            .padding(16)
        }
    }


    private var progressOpacity: CGFloat {
        guard let model = viewModel as? ProgressIndicating else {
            return 0.0
        }
        return model.showProgressView ? 1.0 : 0.0
    }

    private var delay: TimeInterval {
        guard let model = viewModel as? ProgressIndicating else {
            return 0.0
        }
        return model.animationDelay
    }

    private var loadingAccessibilityLabel: Text {
        guard let model = viewModel as? ProgressIndicating else {
            return Text("")
        }
        return Text(model.accessibilityLabel)
    }

    private var infoView: some View {
        VStack {
            if verticalSizeClass != .compact {
                visualAssetView
                .accessibilityHidden(true)
            }

            Text(viewModel.title)
                .fontWeight(.bold)
                .foregroundColor(Color(UIColor.govUK.text.primary))
                .font(Font.govUK.largeTitleBold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .padding(.bottom, 16)
            Text(LocalizedStringKey(viewModel.subtitle))
                .foregroundColor(Color(UIColor.govUK.text.primary))
                .font(viewModel.subtitleFont)
                .multilineTextAlignment(.center)

            customView?()
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var visualAssetView: some View {
        switch viewModel.visualAssetContent {
        case .decorativeImage(let imageName):
            Image(decorative: imageName)
                .padding(.bottom, 16)
        case .systemImage(let imageName):
            Image(systemName: imageName)
                .font(.system(size: 107, weight: .light))
        case .animation(let animationColorSchemeNames):
            let animationName = colorScheme == .light ?
            animationColorSchemeNames.light :
            animationColorSchemeNames.dark
            SwiftUIAnimationView(
                animationName: animationName,
                shouldReduceMotion: true,
                playbackMode: LottieLoopMode.playOnce
            )
            .aspectRatio(contentMode: .fit)
            .frame(maxHeight: 252)
        case .none:
            EmptyView()
        }
    }
}

extension InfoView: TrackableScreen {
    var trackingName: String {
        viewModel.trackingName
    }

    var trackingTitle: String? {
        viewModel.trackingTitle
    }
}
