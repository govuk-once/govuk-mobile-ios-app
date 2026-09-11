import Foundation
import UIKit
import Qualtrics
import GovKitUI

/// See https://api.qualtrics.com/wcri94jmirn8y-theming-creatives-on-android-and-i-os
/// for examples of what each theme component controls.
struct QualtricsThemeBuilder {
    static let primaryButtonTheme = ButtonTheme.init(
        textColor: .govUK.text.buttonPrimary,
        linkColor: .govUK.text.linkSecondary,
        font: .govUK.body,
        backgroundColor: .govUK.text.linkSecondary,
        borderColor: .govUK.text.linkSecondary
    )

    static let secondaryButtonTheme = ButtonTheme.init(
        textColor: .govUK.text.linkSecondary,
        linkColor: .govUK.text.linkSecondary,
        font: .govUK.body,
        backgroundColor: .govUK.fills.surfaceList,
        borderColor: .govUK.text.linkSecondary
    )

    static let thumbsTheme = ThumbButtonTheme.init(
        thumbUpColor: .govUK.text.linkSecondary,
        thumbUpBackground: .govUK.fills.surfaceList,
        thumbDownColor: .govUK.text.linkSecondary,
        thumbDownBackground: .govUK.fills.surfaceList,
        pressedThumbColor: .govUK.text.linkSecondary,
        pressedThumbBackground: .govUK.text.linkSecondary
    )

    static let emojiTheme = EmojiButtonTheme.init(
        backgroundColor: .govUK.text.linkSecondary,
        borderColor: .govUK.text.linkSecondary,
        tintColor: .white
    )

    static let yesNoTheme = YesNoButtonTheme.init(
        yesButtonTitleColor: .white,
        yesButtonFont: .govUK.body,
        yesButtonBackgroundColor: .govUK.text.linkSecondary,
        yesButtonBorderColor: .govUK.text.linkSecondary,
        noButtonTitleColor: .govUK.text.linkSecondary,
        noButtonFont: .govUK.body,
        noButtonBackgroundColor: .govUK.fills.surfaceList,
        noButtonBorderColor: .govUK.text.linkSecondary,
        pressedButtonColor: .govUK.text.linkSecondary,
        pressedButtonBackground: .govUK.text.linkSecondary
    )

    static let starTheme = StarButtonTheme.init(
        backgroundColor: .govUK.fills.surfaceModal,
        tintColor: .govUK.text.linkSecondary,
        pressedTintColor: .govUK.text.linkSecondary,
        pressedBackgroundColor: .govUK.text.linkSecondary
    )

    static let submitTheme = SubmitButtonTheme.init(
        textColor: .govUK.text.buttonPrimary,
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
        questionTextFont: .govUK.title3Semibold,
        otherAnswerTextColor: .govUK.text.primary,
        otherAnswerTextFont: .govUK.body,
        otherAnswerBackgroundColor: .govUK.fills.surfaceBackground,
        radioButtonsTheme: Self.radioButtons
    )

    static let followupQuestionTheme = FollowupQuestionTheme.init(
        color: .govUK.text.primary,
        font: .govUK.title3Semibold,
        textInputColor: .govUK.text.primary,
        textInputFont: .govUK.body,
        textInputBackgroundcolor: .govUK.fills.surfaceBackground
    )
}

extension MobileAppPromptTheme {
    static var govUK: MobileAppPromptTheme {
        MobileAppPromptTheme.init(
            backgroundColor: .govUK.fills.surfaceList,
            headlineTextColor: .govUK.text.primary,
            headlineFont: .govUK.title3Semibold,
            descriptionTextColor: .govUK.text.primary,
            descriptionFont: .govUK.body,
            closeButtonColor: .govUK.text.primary,
            buttonOneTheme: QualtricsThemeBuilder.secondaryButtonTheme,
            buttonTwoTheme: QualtricsThemeBuilder.primaryButtonTheme
        )
    }
}

extension EmbeddedAppFeedbackTheme {
    static var govUK: EmbeddedAppFeedbackTheme {
        EmbeddedAppFeedbackTheme.init(
            dialogBackgroundColor: .govUK.fills.surfaceList,
            dialogShadowColor: .clear,
            closeButtonColor: .govUK.text.primary,
            initialQuestionColor: .govUK.text.primary,
            initialQuestionFont: .govUK.title3Semibold,
            thankYouTextColor: .govUK.text.primary,
            thankYouTextFont: .govUK.title3Semibold,
            followupQuestionTheme: QualtricsThemeBuilder.followupQuestionTheme,
            thumbsButtonsTheme: QualtricsThemeBuilder.thumbsTheme,
            yesNoButtonsTheme: QualtricsThemeBuilder.yesNoTheme,
            starTheme: QualtricsThemeBuilder.starTheme,
            emojiTheme: QualtricsThemeBuilder.emojiTheme,
            submitButtonTheme: QualtricsThemeBuilder.submitTheme,
            multipleChoiceTheme: QualtricsThemeBuilder.multipleChoiceTheme
        )
    }
}
