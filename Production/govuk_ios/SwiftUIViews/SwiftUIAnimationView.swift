import SwiftUI
import Lottie

struct SwiftUIAnimationView: View {
    @Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion
    private var renderingEngine: RenderingEngineOption
    private var animationName: String
    private var animationSpeed: CGFloat
    private var shouldReduceMotion: Bool
    private let reducedAnimationProgress: CGFloat
    private var playbackMode: LottieLoopMode

    init(animationName: String,
         animationSpeed: CGFloat = 1.0,
         renderingEngine: RenderingEngineOption = .mainThread,
         shouldReduceMotion: Bool = true,
         playbackMode: LottieLoopMode = .loop,
         reducedAnimationProgress: CGFloat = 1.0
    ) {
        self.animationName = animationName
        self.animationSpeed = animationSpeed
        self.renderingEngine = renderingEngine
        self.shouldReduceMotion = shouldReduceMotion
        self.playbackMode = playbackMode
        self.reducedAnimationProgress = reducedAnimationProgress
    }

    private var reduceMotion: Bool {
        shouldReduceMotion && accessibilityReduceMotion
    }

    var body: some View {
        let lottieView = LottieView(animation: .named(animationName))
            .configuration(
                LottieConfiguration(
                    renderingEngine: renderingEngine
                )
            )

        if reduceMotion {
            lottieView.currentProgress(reducedAnimationProgress)
        } else {
            lottieView
                .playing(
                    loopMode: playbackMode
                )
                .animationSpeed(animationSpeed)
        }
    }
}
