import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

struct DrivingLicenceSummaryViewModelTests {
    @Test
    func init_formatsLicenceNumberCorrectly() {
        let mockDriverSummary = DriverSummary.arrange(licenceNo: "ABC123AE")
        let sut = DrivingLicenceSummaryViewModel(
            driverSummary: mockDriverSummary,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _ in },
            analyticsService: MockAnalyticsService()
        )
        #expect(sut.licenceNumber == "ABC123AE")
    }

    @Test
    func init_formatsLicenceTypeCorrectly() {
        let mockDriverSummary = DriverSummary.arrange(licenceType: "Provisional")
        let sut = DrivingLicenceSummaryViewModel(
            driverSummary: mockDriverSummary,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _ in },
            analyticsService: MockAnalyticsService()
        )
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
        let sut = DrivingLicenceSummaryViewModel(
            driverSummary: mockDriverSummary,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _ in },
            analyticsService: MockAnalyticsService()
        )
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
        let sut = DrivingLicenceSummaryViewModel(
            driverSummary: mockDriverSummary,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _ in },
            analyticsService: MockAnalyticsService()
        )
        let expectedAddressArray = [
            "1 Leander Drive",
            "Castleton",
            "OL11 4AB"
        ]
        #expect(sut.address == expectedAddressArray)
    }

    @Test
    func init_licenceStatusViewModelIsPopulatedByBuilder() {
        let mockStatusViewModelBuilder = MockLicenceStatusViewModelBuilder()
        mockStatusViewModelBuilder._stubbedViewModel = ValidityStatusViewModel(
            status: "Mock licence status"
        )

        let validToDate = Date.arrange("01/12/2027")
        let mockDriverSummary = DriverSummary.arrange(
            validTo: validToDate
        )
        let sut = DrivingLicenceSummaryViewModel(
            driverSummary: mockDriverSummary,
            statusBuilder: mockStatusViewModelBuilder,
            openURLAction: { _ in },
            analyticsService: MockAnalyticsService()
        )

        #expect(mockStatusViewModelBuilder._makeViewModelCallCount == 1)
        #expect(mockStatusViewModelBuilder._receivedValidToDate == validToDate)
        #expect(sut.licenceStatusViewModel.title == nil)
        #expect(sut.licenceStatusViewModel.status == "Mock licence status")
    }

    @Test
    func init_formatsLicenceTypeAccessibilityLabelCorrectly() {
        let mockDriverSummary = DriverSummary.arrange(licenceType: "Provisional")
        let sut = DrivingLicenceSummaryViewModel(
            driverSummary: mockDriverSummary,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _ in },
            analyticsService: MockAnalyticsService()
        )

        let expectedAccessibilityLabel = String.localizedStringWithFormat(
            String.dvla.localized("licenceTypeAccessibilityLabel"),
            "Provisional licence"
        )
        #expect(sut.licenceTypeAccessibilityLabel == expectedAccessibilityLabel)
    }

    @Test("URLOptions mapping matches expected endpoints and keys", arguments: [
        (DrivingLicenceSummaryViewModel.URLOptions.changeAddresss, Constants.API.dvlaChangeAddressUrl, "changeNameAndGenderMenuTitle"),
        (.replaceLicence, Constants.API.dvlaReplaceDrivingLicence, "replaceLicenceMenuTitle"),
        (.changeNameAndGender, Constants.API.dvlaChangeAddressUrl, "changeNameAndGenderMenuTitle")
    ])
    func urlOptions_returnsCorrectUrlAndTitleKey(
        option: DrivingLicenceSummaryViewModel.URLOptions,
        expectedUrl: URL,
        expectedLocalizationKey: String
    ) {

        let (url, trackingTitle) = option.urlAndTitle
        #expect(url == expectedUrl)
        #expect(trackingTitle == String.dvla.localized(expectedLocalizationKey))
    }

    @Test
    func init_formatsAddressAccessibilityLabelCorrectly() {
        let mockAddress = DriverAddress.arrange(
            line1: "1 LEANDER DRIVE",
            line2: "CASTLETON",
            postcode: "OL11 4AB"
        )
        let mockDriverSummary = DriverSummary.arrange(address: mockAddress)
        let sut = DrivingLicenceSummaryViewModel(
            driverSummary: mockDriverSummary,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _ in },
            analyticsService: MockAnalyticsService()
        )

        let expectedAccessibilityLabel = String.localizedStringWithFormat(
            String.dvla.localized("licenceAddressAccessibilityLabel"),
            "1 Leander Drive, Castleton, OL11 4AB"
        )
        #expect(sut.addressAccessibilityLabel == expectedAccessibilityLabel)
    }
}

