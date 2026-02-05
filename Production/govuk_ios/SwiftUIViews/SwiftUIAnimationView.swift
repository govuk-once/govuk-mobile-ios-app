import SwiftUI
import Lottie

struct SwiftUIAnimationView: View {
    @Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion
    private var renderingEngine: RenderingEngineOption
    private var animationName: String
    private var animationSpeed: CGFloat = 1
    private var shouldReduceMotion: Bool

    init(animationName: String,
         animationSpeed: CGFloat = 1.0,
         renderingEngine: RenderingEngineOption = .mainThread,
         shouldReduceMotion: Bool = true
    ) {
        self.animationName = animationName
        self.animationSpeed = animationSpeed
        self.renderingEngine = renderingEngine
        self.shouldReduceMotion = shouldReduceMotion
    }

    private var reduceMotion: Bool {
        shouldReduceMotion && accessibilityReduceMotion
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
