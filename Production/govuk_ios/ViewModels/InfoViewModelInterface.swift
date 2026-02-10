import Foundation
import SwiftUI
import GovKit
import GovKitUI

enum VisualAssetContent {
    case decorativeImage(String)
    case systemImage(String)
    case animation(AnimationColorSchemeNames)
    case none
}

protocol InfoViewModelInterface: ObservableObject {
    var visualAssetContent: VisualAssetContent { get }
    var analyticsService: AnalyticsServiceInterface? { get }
    var trackingName: String { get }
    var trackingTitle: String { get }

    var navBarHidden: Bool { get }

    var title: String { get }
    var subtitle: String { get }
    var subtitleFont: Font { get }

    var bottomContentText: String? { get }

    var showPrimaryButton: Bool { get }
    var primaryButtonTitle: String { get }
    var primaryButtonAccessibilityTitle: String { get }
    var primaryButtonViewModel: GOVUKButton.ButtonViewModel { get }
    var primaryButtonConfiguration: GOVUKButton.ButtonConfiguration { get }

    var secondaryButtonTitle: String { get }
    var secondaryButtonAccessibilityTitle: String { get }
    var secondaryButtonViewModel: GOVUKButton.ButtonViewModel? { get }
    var secondaryButtonConfiguration: GOVUKButton.ButtonConfiguration { get }
}

protocol ProgressIndicating {
    var showProgressView: Bool { get set }
    var accessibilityLabel: String { get }
    var animationDelay: TimeInterval { get }
}

extension InfoViewModelInterface {
    var visualAssetContent: VisualAssetContent { .none }
    var navBarHidden: Bool { true }

    var subtitle: String { "" }
    var subtitleFont: Font { Font.govUK.body }

    var bottomContentText: String? { nil }

    var showPrimaryButton: Bool { true }

    @MainActor
    var primaryButtonConfiguration: GOVUKButton.ButtonConfiguration { .primary }
    var primaryButtonAccessibilityTitle: String { primaryButtonTitle }

    var secondaryButtonTitle: String { "" }
    var secondaryButtonAccessibilityTitle: String { secondaryButtonTitle }
    var secondaryButtonViewModel: GOVUKButton.ButtonViewModel? { nil }

    @MainActor
    var secondaryButtonConfiguration: GOVUKButton.ButtonConfiguration { .secondary }

    func trackScreen(screen: TrackableScreen) {
        if let analyticsService = analyticsService {
            analyticsService.track(screen: screen)
        }
    }
}

struct AnimationColorSchemeNames {
    let light: String
    let dark: String
}
