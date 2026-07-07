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
            analyticsService: MockAnalyticsService()
        )
        #expect(sut.licenceNumber == "ABC123AE")
    }

    @Test
    func openUrl_changeAddresss_tracksExpectedNavigationEvent() {
        let mockDriverSummary = DriverSummary.arrange(licenceNo: "ABC123AE")
        let mockAnalytics = MockAnalyticsService()
        let sut = DrivingLicenceSummaryViewModel(
            driverSummary: mockDriverSummary,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            analyticsService: mockAnalytics
        )

        sut.openUrl(options: .changeAddresss)

        #expect(mockAnalytics._trackedEvents.count == 1)

        guard let event = mockAnalytics._trackedEvents.first else {
            return
        }
        #expect(event.name == "Navigation")
        #expect(event.params?["text"] as? String == "Change address")
        #expect(event.params?["type"] as? String == "Menu")
        #expect(event.params?["external"] as? Bool == true)
    }

    @Test
    func openUrl_replaceLicence_tracksExpectedNavigationEvent() {
        let mockDriverSummary = DriverSummary.arrange(licenceNo: "ABC123AE")
        let mockAnalytics = MockAnalyticsService()
        let sut = DrivingLicenceSummaryViewModel(
            driverSummary: mockDriverSummary,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            analyticsService: mockAnalytics
        )

        sut.openUrl(options: .replaceLicence)

        #expect(mockAnalytics._trackedEvents.count == 1)

        guard let event = mockAnalytics._trackedEvents.first else {
            return
        }

        #expect(event.name == "Navigation")
        #expect(event.params?["text"] as? String == "Replace licence")
        #expect(event.params?["type"] as? String == "Menu")
        #expect(event.params?["external"] as? Bool == true)
    }

    @Test
    func copyToClipboard_tracksExpectedCopyEvent() {
        let mockDriverSummary = DriverSummary.arrange(licenceNo: "ABC123AE")
        let mockAnalytics = MockAnalyticsService()
        let sut = DrivingLicenceSummaryViewModel(
            driverSummary: mockDriverSummary,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            analyticsService: mockAnalytics
        )
        sut.copyToClipbaord()

        #expect(mockAnalytics._trackedEvents.count == 1)

        guard let event = mockAnalytics._trackedEvents.first else {
            return
        }

        #expect(event.name == "Function")
        #expect(event.params?["text"] as? String == "Copy to clipboard")
        #expect(event.params?["type"] as? String == "Menu")
        #expect(event.params?["section"] as? String == "Driver account")
        #expect(event.params?["action"] as? String == "Copy")
    }

    @Test
    func init_formatsLicenceTypeCorrectly() {
        let mockDriverSummary = DriverSummary.arrange(licenceType: "Provisional")
        let sut = DrivingLicenceSummaryViewModel(
            driverSummary: mockDriverSummary,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
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
            analyticsService: MockAnalyticsService()
        )

        let expectedAccessibilityLabel = String.localizedStringWithFormat(
            String.dvla.localized("licenceTypeAccessibilityLabel"),
            "Provisional licence"
        )
        #expect(sut.licenceTypeAccessibilityLabel == expectedAccessibilityLabel)
    }

    @Test
    func changeAddress_returnsCorrectUrlAndTitle() {
        let option = DrivingLicenceSummaryViewModel.URLOptions.changeAddresss
        let expectedUrl = Constants.API.dvlaChangeAddressUrl
        let (actualUrl, actualTitle) = option.urlAndTitle

        #expect(actualUrl == expectedUrl)
        #expect(actualTitle == "Change address")
    }

    @Test
    func replaceLicence_returnsCorrectUrlAndTitle() {
        let option = DrivingLicenceSummaryViewModel.URLOptions.replaceLicence
        let expectedUrl = Constants.API.dvlaReplaceDrivingLicence
        let (actualUrl, actualTitle) = option.urlAndTitle

        #expect(actualUrl == expectedUrl)
        #expect(actualTitle == "Replace licence")
    }

    @Test
    func changeNameAndGender_returnsCorrectUrlAndTitle() {
        let option = DrivingLicenceSummaryViewModel.URLOptions.changeNameAndGender
        let expectedUrl = Constants.API.dvlaChangeAddressUrl
        let (actualUrl, actualTitle) = option.urlAndTitle

        #expect(actualUrl == expectedUrl)
        #expect(actualTitle == "Change name or gender")
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
            analyticsService: MockAnalyticsService()
        )

        let expectedAccessibilityLabel = String.localizedStringWithFormat(
            String.dvla.localized("licenceAddressAccessibilityLabel"),
            "1 Leander Drive, Castleton, OL11 4AB"
        )
        #expect(sut.addressAccessibilityLabel == expectedAccessibilityLabel)
    }
}
