import SwiftUI
import Lottie

struct SwiftUIAnimationView: View {
    var renderingEngine: RenderingEngineOption
    var animationName: String
    var animationSpeed: CGFloat = 1

    init(animationName: String,
         animationSpeed: CGFloat = 1.0,
         renderingEngine: RenderingEngineOption = .mainThread
    ) {
        self.animationName = animationName
        self.animationSpeed = animationSpeed
        self.renderingEngine = renderingEngine
    }

    var body: some View {
        LottieView(animation: .named(
            animationName)
        )
        .configuration(
            LottieConfiguration(
                renderingEngine: renderingEngine
            )
        )
        .playing(
            loopMode: .loop
        )
        .animationSpeed(animationSpeed)
    }
}
