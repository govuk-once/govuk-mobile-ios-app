import Foundation
import GovKitUI
import GovKit
import SwiftUI

class LocalWasteAddressSelectionViewModel: ObservableObject {
    @Published
    private(set) var addresses: [LocalWasteAddress]
    @Published
    var selectedAddress: LocalWasteAddress?

    private let analyticsService: AnalyticsServiceInterface
    private let service: LocalWasteServiceInterface
    private let doneAction: () -> Void

    let dismissAction: () -> Void

    let title = String.localWaste.localized(
        "localWasteAddressSelectionViewTitle"
    )
    let subtitle = String.localWaste.localized(
        "localWasteAddressSelectionViewSubtitle"
    )
    let cancelButton: String = String.common.localized(
        "cancel"
    )
    let primaryButton: String = String.localWaste.localized(
        "localWasteAddressSelectionViewPrimaryButton"
    )

    init(service: LocalWasteServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         addresses: [LocalWasteAddress],
         dismissAction: @escaping () -> Void,
         doneAction: @escaping () -> Void
     ) {
        self.analyticsService = analyticsService
        self.service = service
        self.addresses = addresses
        self.dismissAction = dismissAction
        self.doneAction = doneAction
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    func confirmAddress() {
        guard let selectedAddress = selectedAddress else { return }

        service.saveAddress(selectedAddress)

        trackNavigationEvent(primaryButton)
        doneAction()
    }

    private func trackNavigationEvent(_ title: String) {
        let event = AppEvent.buttonNavigation(
            text: title,
            external: true
        )
        analyticsService.track(event: event)
    }
}
