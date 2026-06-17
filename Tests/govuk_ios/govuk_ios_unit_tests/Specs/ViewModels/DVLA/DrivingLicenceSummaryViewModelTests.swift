import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

struct DrivingLicenceSummaryViewModelTests {
    @Test
    func init_formatsLicenceNumberCorrectly() {
        let mockDriverSummary = DriverSummary.arrange(licenceNo: "ABC123AE")
        let sut = DrivingLicenceSummaryViewModel(driverSummary: mockDriverSummary)
        #expect(sut.licenceNumber == "ABC123AE")
    }

    @Test
    func init_formatsLicenceTypeCorrectly() {
        let mockDriverSummary = DriverSummary.arrange(licenceType: "Provisional")
        let sut = DrivingLicenceSummaryViewModel(driverSummary: mockDriverSummary)
        let expectedLicenceType = String.localizedStringWithFormat(
            String.dvla.localized("licenceType"),
            "Provisional")
        #expect(sut.licenceType == expectedLicenceType)
    }

    @Test
    func init_formatsFullNameCorrectly() {
        let mockDriverSummary = DriverSummary.arrange(
            title: "MR",
            firstNames: "JOE GEORGE",
            lastName: "BLOGGS"
        )
        let sut = DrivingLicenceSummaryViewModel(driverSummary: mockDriverSummary)
        #expect(sut.fullName == "MR JOE GEORGE BLOGGS")
    }

    @Test
    func init_formatsAddressCorrectly() {
        let mockAddress = DriverAddress.arrange(
            line1: "1 LEANDER DRIVE",
            line2: "CASTLETON",
            postcode: "OL11 4AB"
        )
        let mockDriverSummary = DriverSummary.arrange(
            address: mockAddress
        )
        let sut = DrivingLicenceSummaryViewModel(driverSummary: mockDriverSummary)
        let expectedAddressArray = [
            "1 Leander Drive",
            "Castleton",
            "OL11 4AB"
        ]
        #expect(sut.address == expectedAddressArray)
    }

    @Test
    func init_licenceValidToDateIsValid_formatsLicenceStatusCorrectly() {
        let validToDate = Date.arrange("01/12/2027")
        let mockDriverSummary = DriverSummary.arrange(
            validTo: validToDate
        )
        let sut = DrivingLicenceSummaryViewModel(driverSummary: mockDriverSummary)

        let expectedDateString = DateFormatter.dvlaAccount.string(from: validToDate)
        let expectedStatusString = String.localizedStringWithFormat(
            String.dvla.localized("validUntil"),
            expectedDateString)
        #expect(sut.licenceStatusViewModel.title == nil)
        #expect(sut.licenceStatusViewModel.status == expectedStatusString)
    }

    @Test
    func init_formatsLicenceTypeAccessibilityLabelCorrectly() {
        let mockDriverSummary = DriverSummary.arrange(licenceType: "Provisional")
        let sut = DrivingLicenceSummaryViewModel(driverSummary: mockDriverSummary)

        let expectedAccessibilityLabel = String.localizedStringWithFormat(
            String.dvla.localized("licenceTypeAccessibilityLabel"),
            "Provisional licence"
        )
        #expect(sut.licenceTypeAccessibilityLabel == expectedAccessibilityLabel)
    }

    @Test
    func init_formatsAddressAccessibilityLabelCorrectly() {
        let mockAddress = DriverAddress.arrange(
            line1: "1 LEANDER DRIVE",
            line2: "CASTLETON",
            postcode: "OL11 4AB"
        )
        let mockDriverSummary = DriverSummary.arrange(address: mockAddress)
        let sut = DrivingLicenceSummaryViewModel(driverSummary: mockDriverSummary)

        let expectedAccessibilityLabel = String.localizedStringWithFormat(
            String.dvla.localized("licenceAddressAccessibilityLabel"),
            "1 Leander Drive, Castleton, OL11 4AB"
        )
        #expect(sut.addressAccessibilityLabel == expectedAccessibilityLabel)
    }

    @Test
    func init_formatsLicenceStatusAccessibilityLabelCorrectly() {
        let validToDate = Date.arrange("01/12/2027")
        let mockDriverSummary = DriverSummary.arrange(
            validTo: validToDate
        )
        let sut = DrivingLicenceSummaryViewModel(driverSummary: mockDriverSummary)

        let expectedDateString = DateFormatter.dvlaAccount.string(from: validToDate)
        let expectedStatusString = String.localizedStringWithFormat(
            String.dvla.localized("validUntil"),
            expectedDateString)

        let expectedAccessibilityLabel = String.localizedStringWithFormat(
            String.dvla.localized("licenceStatusAccessibilityLabel"),
            expectedStatusString
        )
        #expect(sut.licenceStatusAccessibilityLabel == expectedAccessibilityLabel)
    }
}
