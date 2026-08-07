import Foundation
import UIKit
import Qualtrics
import GovKitUI

/// See https://api.qualtrics.com/wcri94jmirn8y-theming-creatives-on-android-and-i-os
/// for examples of what each theme component controls.
struct QualtricsThemeBuilder {
    static let primaryButtonTheme = ButtonTheme.init(
        textColor: .govUK.text.buttonPrimary,
        linkColor: .govUK.text.link,
        font: .govUK.body,
        backgroundColor: .govUK.fills.surfaceButtonPrimary,
        borderColor: .clear
    )

    static let secondaryButtonTheme = ButtonTheme.init(
        textColor: .govUK.text.buttonSecondary,
        linkColor: .govUK.text.link,
        font: .govUK.body,
        backgroundColor: .govUK.fills.surfaceButtonSecondary,
        borderColor: .clear
    )

    static let thumbsTheme = ThumbButtonTheme.init(
        thumbUpColor: .white,
        thumbUpBackground: .govUK.fills.surfaceButtonPrimary,
        thumbDownColor: .white,
        thumbDownBackground: .govUK.fills.surfaceButtonDestructive,
        pressedThumbColor: .white,
        pressedThumbBackground: .govUK.fills.surfaceButtonPrimaryHighlight
    )

    static let yesNoTheme = YesNoButtonTheme.init(
        yesButtonTitleColor: .govUK.text.buttonPrimary,
        yesButtonFont: .govUK.body,
        yesButtonBackgroundColor: .govUK.fills.surfaceButtonPrimary,
        yesButtonBorderColor: .clear,
        noButtonTitleColor: .govUK.text.buttonPrimary,
        noButtonFont: .govUK.body,
        noButtonBackgroundColor: .govUK.fills.surfaceButtonDestructive,
        noButtonBorderColor: .clear,
        pressedButtonColor: .govUK.fills.surfaceBackground,
        pressedButtonBackground: .govUK.fills.surfaceChatBackground
    )

    static let starTheme = StarButtonTheme.init(
        backgroundColor: .govUK.fills.surfaceModal,
        tintColor: .govUK.fills.surfaceButtonPrimary,
        pressedTintColor: .govUK.fills.surfaceButtonPrimary,
        pressedBackgroundColor: .govUK.fills.surfaceModal
    )

    static let submitTheme = SubmitButtonTheme.init(
        textColor: .govUK.text.primary,
        font: .govUK.body,
        fillColor: .govUK.fills.surfaceButtonPrimary,
        separatorColor: .govUK.strokes.listDivider
    )

    static let radioButtons = RadioButtonTheme.init(
        textColor: .govUK.text.primary,
        font: .govUK.body,
        borderColor: .govUK.text.primary,
        selectedBorderColor: .govUK.text.primary,
        backgroundColor: .govUK.fills.surfaceModal,
        selectedBackgroundColor: .govUK.fills.surfaceModal,
        fillColor: .govUK.text.primary,
        selectedFillColor: .govUK.text.primary
    )

    static let multipleChoiceTheme = MultipleChoiceTheme.init(
        questionTextColor: .govUK.text.primary,
        questionTextFont: .govUK.body,
        otherAnswerTextColor: .govUK.text.primary,
        otherAnswerTextFont: .govUK.body,
        otherAnswerBackgroundColor: .govUK.fills.surfaceBackground,
        radioButtonsTheme: Self.radioButtons
    )

    static let followupQuestionTheme = FollowupQuestionTheme.init(
        color: .govUK.fills.surfaceModal,
        textInputColor: .govUK.text.primary,
        textInputFont: .govUK.body,
        textInputBackgroundcolor: .govUK.fills.surfaceBackground
    )
}

extension MobileAppPromptTheme {
    static var govUK: MobileAppPromptTheme {
        MobileAppPromptTheme.init(
            backgroundColor: .govUK.fills.surfaceModal,
            headlineTextColor: .govUK.text.primary,
            headlineFont: .govUK.headlineSemibold,
            descriptionTextColor: .govUK.text.secondary,
            descriptionFont: .govUK.body,
            buttonOneTheme: QualtricsThemeBuilder.secondaryButtonTheme,
            buttonTwoTheme: QualtricsThemeBuilder.primaryButtonTheme
        )
    }
}

extension EmbeddedAppFeedbackTheme {
    static var govUK: EmbeddedAppFeedbackTheme {
        EmbeddedAppFeedbackTheme.init(
            dialogBackgroundColor: .govUK.fills.surfaceModal,
            dialogShadowColor: .clear,
            closeButtonColor: .govUK.text.primary,
            initialQuestionColor: .govUK.text.primary,
            initialQuestionFont: .govUK.title3,
            thankYouTextColor: .govUK.text.primary,
            thankYouTextFont: .govUK.title3,
            followupQuestionTheme: QualtricsThemeBuilder.followupQuestionTheme,
            thumbsButtonsTheme: QualtricsThemeBuilder.thumbsTheme,
            yesNoButtonsTheme: QualtricsThemeBuilder.yesNoTheme,
            starTheme: QualtricsThemeBuilder.starTheme,
            submitButtonTheme: QualtricsThemeBuilder.submitTheme,
            multipleChoiceTheme: QualtricsThemeBuilder.multipleChoiceTheme
        )
    }
}
