import Foundation
import GovKitUI
import GovKit
import SwiftUI

class LocalWastePostcodeEntryViewModel: ObservableObject {
    @Published var postCode: String = ""
    @Published var error: PostcodeError?
    @Published var textFieldColour: UIColor = UIColor.govUK.strokes.listDivider

    private let analyticsService: AnalyticsServiceInterface

    let dismissAction: () -> Void

    let cancelButton: String = String.common.localized(
        "cancel"
    )
    let viewTitle: String =  String.localWaste.localized(
        "localWastePostcodeEntryViewTitle"
    )
    let exampleText: String = String.localWaste.localized(
        "localWastePostcodeEntryViewExampleText"
    )
    let descriptionTitle: String = String.localWaste.localized(
        "localWastePostcodeEntryViewDescriptionTitle"
    )
    let descriptionBody: String = String.localWaste.localized(
        "localWastePostcodeEntryViewDescriptionBody"
    )
    let entryFieldAccessibilityLabel: String = String.localWaste.localized(
        "localWastePostcodeEntryViewEntryAccessibilityLabel"
    )
    private let primaryButton: String = String.localWaste.localized(
        "localWastePostcodeEntryViewPrimaryButton"
    )

    init(analyticsService: AnalyticsServiceInterface,
         dismissAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.dismissAction = dismissAction
    }

    enum PostcodeError: String {
        case textFieldEmpty = "localWastePostcodeEntryViewEmptyPostcode"

        var errorMessage: String {
            String.localWaste.localized(
                rawValue
            )
        }
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        .init(
            localisedTitle: primaryButton,
            action: { [weak self] in
                guard let self = self else { return }
                if postCode.isEmpty {
                    self.error = .textFieldEmpty
                    self.setErrorTextFieldColour()
                    return
                }
                let buttonTitle = self.primaryButton
                self.trackNavigationEvent(buttonTitle)
                
//                let sanitisedPostcode = self.preprocessTextInput(
//                    postcode: postCode
//                )
                // TODO fetch addresses here
            }
        )
    }

    private func trackNavigationEvent(_ title: String) {
        let event = AppEvent.buttonNavigation(
            text: title,
            external: true
        )
        analyticsService.track(event: event)
    }

//    private func preprocessTextInput(postcode: String) -> String {
//        let upperCasedText = postcode.uppercased()
//        let textWithoutUnderScores = upperCasedText.replacingOccurrences(
//            of: "_",
//            with: ""
//        )
//        let removedWhiteSpace = textWithoutUnderScores.filter {!$0.isWhitespace}
//        return removedWhiteSpace
//    }

    private func setErrorTextFieldColour() {
        textFieldColour = UIColor.govUK.strokes.error
    }
}
