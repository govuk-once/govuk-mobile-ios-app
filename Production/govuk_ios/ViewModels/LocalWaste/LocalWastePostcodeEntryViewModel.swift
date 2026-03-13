import Foundation
import GovKitUI
import GovKit
import SwiftUI

@MainActor
class LocalWastePostcodeEntryViewModel: ObservableObject {
    @Published
    var postcode: String = "" {
        didSet {
            if postcode != oldValue {
                populateErrorMessage(nil)
            }
        }
    }

    @Published
    var error: PostcodeError?

    @Published
    var textFieldColour: UIColor = UIColor.govUK.strokes.listDivider

    @Published
    var isLoading = false

    @Published
    var isPrimaryButtonEnabled = false

    private let analyticsService: AnalyticsServiceInterface
    private let service: LocalWasteServiceInterface
    private let doneAction: ([LocalWasteAddress]) -> Void

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
    let primaryButton: String = String.localWaste.localized(
        "localWastePostcodeEntryViewPrimaryButton"
    )

    init(service: LocalWasteServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         dismissAction: @escaping () -> Void,
         doneAction: @escaping ([LocalWasteAddress]) -> Void) {
        self.service = service
        self.analyticsService = analyticsService
        self.dismissAction = dismissAction
        self.doneAction = doneAction
    }

    enum PostcodeError: String {
        case textFieldEmpty = "localWastePostcodeEntryViewEmptyPostcode"
        case pageNotWorking = "localWastePageNotWorking"

        var errorMessage: String {
            String.localWaste.localized(
                rawValue
            )
        }
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    func fetchAddresses() async {
        if postcode.isEmpty {
            populateErrorMessage(.textFieldEmpty)
            return
        }

        do {
            isLoading = true
            let sanitisedPostcode = preprocessTextInput(postcode: postcode)
            let addresses = try await service.fetchAddresses(postcode: sanitisedPostcode)
            if addresses.count == 0 {
                throw LocalWasteAddressSearchError.unknownPostcode
            }

            trackNavigationEvent(primaryButton)
            doneAction(addresses)
            isLoading = false
        } catch {
            isLoading = false
            populateErrorMessage(.pageNotWorking)
        }
    }

    private func populateErrorMessage(_ error: PostcodeError?) {
        self.error = error
        textFieldColour = error == nil
        ? UIColor.govUK.strokes.listDivider
        : UIColor.govUK.strokes.error
    }

    private func trackNavigationEvent(_ title: String) {
        let event = AppEvent.buttonNavigation(
            text: title,
            external: true
        )
        analyticsService.track(event: event)
    }

    private func preprocessTextInput(postcode: String) -> String {
        let upperCasedText = postcode.uppercased()
        let textWithoutUnderScores = upperCasedText.replacingOccurrences(
            of: "_",
            with: ""
        )
        let removedWhiteSpace = textWithoutUnderScores.filter {!$0.isWhitespace}
        return removedWhiteSpace
    }
}
