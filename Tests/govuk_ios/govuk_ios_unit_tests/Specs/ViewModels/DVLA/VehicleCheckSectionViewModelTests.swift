import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@MainActor
@Suite
struct VehicleCheckSectionViewModelTests {
    @Test
    func buttonTitle_returnsExpectedResult() {
        let sut = VehicleCheckSectionViewModel(action: { _ in })
        #expect(sut.buttonTitle == String(localized: .DVLA.vehicleCheckButtonTitle))
    }
}
