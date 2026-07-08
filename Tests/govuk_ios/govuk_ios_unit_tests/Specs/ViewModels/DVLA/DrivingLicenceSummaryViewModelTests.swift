import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

struct DrivingLicenceSummaryViewModelTests {
    @Test
    func init_formatsLicenceNumberCorrectly() {
        let mockDrivingLicence = DrivingLicence.arrange(licenceNumber: "ABC123AE")
        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _, _ in }
        )
        #expect(sut.licenceNumber == "ABC123AE")
    }

    @Test
    func init_formatsLicenceTypeCorrectly() {
        let mockDrivingLicence = DrivingLicence.arrange(licenceType: "Provisional")
        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _, _ in }
        )
        let expectedLicenceType = String.localizedStringWithFormat(
            String.dvla.localized("licenceType"),
            "Provisional")
        #expect(sut.licenceType == expectedLicenceType)
    }

    @Test
    func init_formatsFullNameCorrectly() {
        let mockDrivingLicence = DrivingLicence.arrange(
            driverTitle: "MR",
            driverFirstNames: "JOE GEORGE",
            driverLastName: "BLOGGS"
        )
        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _, _ in }
        )
        #expect(sut.fullName == "MR JOE GEORGE BLOGGS")
    }

    @Test
    func init_licenceStatusViewModelIsPopulatedByBuilder() {
        let mockStatusViewModelBuilder = MockLicenceStatusViewModelBuilder()
        mockStatusViewModelBuilder._stubbedViewModel = ValidityStatusViewModel(
            formattedStatus: "Mock licence status"
        )

        let validToDate = Date.arrange("01/12/2027")
        let mockDrivingLicence = DrivingLicence.arrange(
            tokenValidToDate: validToDate
        )
        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: mockStatusViewModelBuilder,
            openURLAction: { _, _ in }
        )

        #expect(mockStatusViewModelBuilder._makeViewModelCallCount == 1)
        #expect(mockStatusViewModelBuilder._receivedValidToDate == validToDate)
        #expect(sut.licenceStatusViewModel.title == nil)
        #expect(sut.licenceStatusViewModel.formattedStatus == "Mock licence status")
    }

    @Test
    func init_formatsLicenceTypeAccessibilityLabelCorrectly() {
        let mockDrivingLicence = DrivingLicence.arrange(licenceType: "Provisional")
        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _, _ in }
        )

        let expectedAccessibilityLabel = String.localizedStringWithFormat(
            String.dvla.localized("licenceTypeAccessibilityLabel"),
            "Provisional licence"
        )
        #expect(sut.licenceTypeAccessibilityLabel == expectedAccessibilityLabel)
    }

    @Test
    func init_formatsAddressAccessibilityLabelCorrectly() {
        let mockAddress = "1 LEANDER DRIVE\nCASTLETON\nOL11 4AB"
        let mockDrivingLicence = DrivingLicence.arrange(driverFullAddress: mockAddress)
        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _, _ in }
        )

        let expectedAccessibilityLabel = String.localizedStringWithFormat(
            String.dvla.localized("licenceAddressAccessibilityLabel"),
            "1 LEANDER DRIVE, CASTLETON, OL11 4AB"
        )
        #expect(sut.addressAccessibilityLabel == expectedAccessibilityLabel)
    }
}
