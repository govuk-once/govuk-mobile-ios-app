import Foundation
import UIKit
import GovKitUI

@MainActor
extension GOVUKButton.ButtonConfiguration {
    public static var text: GOVUKButton.ButtonConfiguration {
        .init(
            titleColorNormal: UIColor.govUK.text.link,
            titleColorHighlighted: UIColor.govUK.text.link,
            titleColorFocused: UIColor.govUK.text.link,
            titleColorDisabled: UIColor.govUK.text.link,
            titleFont: UIFont.govUK.body,
            contentEdgeInsets: .init(top: 8, left: 0, bottom: 8, right: 0),
            backgroundColorNormal: .clear,
            backgroundColorHighlighted: .clear,
            backgroundColorFocused: .clear,
            backgroundColorDisabled: .clear,
            cornerRadius: 0,
            borderColorNormal: .clear,
            borderColorHighlighted: .clear,
            accessibilityButtonShapesColor: .blue,
            shadowColor: UIColor.clear.cgColor,
            shadowRadius: 0,
            shadowHighLightedColor: UIColor.clear.cgColor,
            shadowFocusedColor: UIColor.clear.cgColor
        )
    }

    public static var blackPrimaryButton: GOVUKButton.ButtonConfiguration {
        .init(
            titleColorNormal: UIColor.govUK.text.linkAccountButton,
            titleColorHighlighted: UIColor.govUK.text.linkAccountButtonHighlight,
            titleColorFocused: UIColor.govUK.text.buttonPrimaryFocussed,
            titleColorDisabled: UIColor.govUK.text.linkAccountButtonHighlight,
            titleFont: UIFont.govUK.bodySemibold,
            backgroundColorNormal: UIColor.govUK.fills.linkAccountButton,
            backgroundColorHighlighted: UIColor.govUK.fills.linkAccountButtonHighlight,
            backgroundColorFocused: UIColor.govUK.fills.surfaceButtonPrimaryFocussed,
            backgroundColorDisabled: UIColor.govUK.fills.linkAccountButtonHighlight,
            cornerRadius: 15,
            accessibilityButtonShapesColor: UIColor.grey100,
            shadowColor: UIColor.govUK.strokes.linkAccountButton.cgColor,
            shadowHighLightedColor: UIColor.govUK.strokes.linkAccountButtonHighlight.cgColor,
            shadowFocusedColor: UIColor.govUK.strokes.buttonFocused.cgColor
        )
    }
}
