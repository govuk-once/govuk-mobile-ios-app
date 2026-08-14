import Foundation
import UIKit
import CoreData
import GovKit

final class TravelTopicWidgetViewModel: ObservableObject {
    // Drives .sheet(isPresented:) in the widget view
    @Published var isShowingList = false

    private let linkAction: () -> Void
    private let dismissAction: () -> Void

    init(
        linkAction: @escaping () -> Void = {},
        dismissAction: @escaping () -> Void = {}
    ) {
        self.linkAction = linkAction
        self.dismissAction = dismissAction
    }

    func openCountryList() {
        isShowingList = true
    }

    func didDismissList() {
        isShowingList = false
        dismissAction()
    }
}
