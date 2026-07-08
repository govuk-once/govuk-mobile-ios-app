import Foundation
import GovKit
import GovKitUI

@testable import govuk_ios

class MockLicenceStatusViewModelBuilder: LicenceStatusViewModelBuilderInterface {
    var _stubbedViewModel: ValidityStatusViewModel = .init(
        formattedStatus: "Valid until 1 January 1970",
        iconName: "checkmark.circle.fill",
        iconTintColour: .govUK.fills.surfaceButtonPrimary
    )
    var _makeViewModelCallCount = 0
    var _receivedStatus: DrivingLicenceStatus?
    var _receivedValidToDate: Date?
    var _receivedOpenURLAction: ((URL, String) -> Void)?

    func makeViewModel(
       status: DrivingLicenceStatus,
       validToDate: Date?,
       openURLAction: @escaping (URL, String) -> Void
    ) -> ValidityStatusViewModel {
        _makeViewModelCallCount += 1
        _receivedStatus = status
        _receivedValidToDate = validToDate
        _receivedOpenURLAction = openURLAction
        return _stubbedViewModel
    }
}
