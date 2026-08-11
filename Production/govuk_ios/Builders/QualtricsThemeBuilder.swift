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
        thumbUpColor: .qualtricsPurple,
        thumbUpBackground: .govUK.fills.surfaceList,
        thumbDownColor: .qualtricsPurple,
        thumbDownBackground: .govUK.fills.surfaceList,
        pressedThumbColor: .qualtricsPurple,
        pressedThumbBackground: .qualtricsPurple
    )

    static let emojiTheme = EmojiButtonTheme.init(
        backgroundColor: .qualtricsPurple,
        borderColor: .qualtricsPurple,
        tintColor: .white
    )

    static let yesNoTheme = YesNoButtonTheme.init(
        yesButtonTitleColor: .white,
        yesButtonFont: .govUK.body,
        yesButtonBackgroundColor: .qualtricsPurple,
        yesButtonBorderColor: .qualtricsPurple,
        noButtonTitleColor: .qualtricsPurple,
        noButtonFont: .govUK.body,
        noButtonBackgroundColor: .govUK.fills.surfaceList,
        noButtonBorderColor: .qualtricsPurple,
        pressedButtonColor: .qualtricsPurple,
        pressedButtonBackground: .qualtricsPurple
    )

    static let starTheme = StarButtonTheme.init(
        backgroundColor: .govUK.fills.surfaceModal,
        tintColor: .qualtricsPurple,
        pressedTintColor: .qualtricsPurple,
        pressedBackgroundColor: .qualtricsPurple
    )

    static let submitTheme = SubmitButtonTheme.init(
        textColor: .white,
        font: .govUK.body,
        fillColor: .qualtricsPurple,
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
