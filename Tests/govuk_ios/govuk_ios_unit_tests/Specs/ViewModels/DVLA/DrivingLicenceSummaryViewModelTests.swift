import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

struct DrivingLicenceSummaryViewModelTests {

    @Test
    func test_formatsLicenceNumberCorrectly() {
        let mockDrivingLicence = DrivingLicence.arrange(
            licenceType: "Full",
            licenceNumber: "ABC123AE",
            driverTitle: "Mr",
            driverFirstNames: "John",
            driverLastName: "Doe",
            driverFullAddress: "123 Test Street\nLondon",
            licenceStatus: .valid
        )

        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _, _ in },
            menuSelectionAction: { _ in },
            copyToClipboardAction: { _ in },
            analyticsService: MockAnalyticsService()
        )

        #expect(sut.licenceNumber == "ABC123AE")
    }

    @Test
    func openUrl_changeAddresss_tracksExpectedNavigationEvent() {
        let mockDrivingLicence = DrivingLicence.arrange(
            licenceType: "Full",
            licenceNumber: "ABC123AE",
            driverTitle: "Mr",
            driverFirstNames: "John",
            driverLastName: "Doe",
            driverFullAddress: "123 Test Street\nLondon",
            licenceStatus: .valid
        )
        let mockAnalytics = MockAnalyticsService()
        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _, _ in },
            menuSelectionAction: { _ in },
            copyToClipboardAction: { _ in },
            analyticsService: mockAnalytics
        )

        sut.openUrl(options: .changeAddress)

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
        let mockDrivingLicence = DrivingLicence.arrange(
            licenceType: "Full",
            licenceNumber: "ABC123AE",
            driverTitle: "Mr",
            driverFirstNames: "John",
            driverLastName: "Doe",
            driverFullAddress: "123 Test Street\nLondon",
            licenceStatus: .valid
        )
        let mockAnalytics = MockAnalyticsService()
        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _, _ in },
            menuSelectionAction: { _ in },
            copyToClipboardAction: { _ in },
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
    func changeAddress_returnsCorrectUrlAndTitle() {
        let option = DrivingLicenceSummaryViewModel.URLOptions.changeAddress
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
        let expectedUrl = Constants.API.dvlaChangeNameAndGenderDrivingLicence
        let (actualUrl, actualTitle) = option.urlAndTitle

        #expect(actualUrl == expectedUrl)
        #expect(actualTitle == "Change name or gender")
    }

    @Test
    func init_formatsLicenceTypeCorrectly() {
        let mockDrivingLicence = DrivingLicence.arrange(
            licenceType: "Provisional",
            licenceNumber: "ABC123AE",
            driverTitle: "Mr",
            driverFirstNames: "John",
            driverLastName: "Doe",
            driverFullAddress: "123 Test Street\nLondon",
            licenceStatus: .valid
        )
        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _, _ in },
            menuSelectionAction: { _ in },
            copyToClipboardAction: { _ in },
            analyticsService: MockAnalyticsService()
        )
        let expectedLicenceType = String.localizedStringWithFormat(
            String.dvla.localized("licenceType"),
            "Provisional"
        )
        #expect(sut.licenceType == expectedLicenceType)
    }

    @Test
    func init_formatsFullNameCorrectly() {
        let mockDrivingLicence = DrivingLicence.arrange(
            licenceType: "Full",
            licenceNumber: "ABC123AE",
            driverTitle: "MR",
            driverFirstNames: "JOE GEORGE",
            driverLastName: "BLOGGS",
            driverFullAddress: "123 Test Street\nLondon",
            licenceStatus: .valid
        )
        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: MockLicenceStatusViewModelBuilder(),
            openURLAction: { _, _ in },
            menuSelectionAction: { _ in },
            copyToClipboardAction: { _ in },
            analyticsService: MockAnalyticsService()
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
            licenceType: "Full",
            licenceNumber: "ABC123AE",
            driverTitle: "Mr",
            driverFirstNames: "John",
            driverLastName: "Doe",
            driverFullAddress: "123 Test Street\nLondon",
            tokenValidToDate: validToDate,
            licenceStatus: .valid
        )

        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: mockStatusViewModelBuilder,
            openURLAction: { _, _ in },
            menuSelectionAction: { _ in },
            copyToClipboardAction: { _ in },
            analyticsService: MockAnalyticsService()
        )
        #expect(mockStatusViewModelBuilder._receivedValidToDate == validToDate)
        #expect(sut.licenceStatusViewModel.title == nil)
        #expect(mockStatusViewModelBuilder._makeViewModelCallCount == 1)
        #expect(sut.licenceStatusViewModel.formattedStatus == "Mock licence status")
    }

    @Test
    func init_formatsLicenceTypeAccessibilityLabelCorrectly() {
        let mockStatusViewModelBuilder = MockLicenceStatusViewModelBuilder()
        mockStatusViewModelBuilder._stubbedViewModel = ValidityStatusViewModel(
            formattedStatus: "Mock licence status"
        )
        let mockDrivingLicence = DrivingLicence.arrange(licenceType: "Provisional")
        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: mockStatusViewModelBuilder,
            openURLAction: { _, _ in },
            menuSelectionAction: { _ in },
            copyToClipboardAction: { _ in },
            analyticsService: MockAnalyticsService()
        )


        let expectedAccessibilityLabel = String.localizedStringWithFormat(
            String.dvla.localized("licenceTypeAccessibilityLabel"),
            "Provisional licence"
        )
        #expect(sut.licenceTypeAccessibilityLabel == expectedAccessibilityLabel)
    }

    @Test
    func init_formatsAddressAccessibilityLabelCorrectly() {
        let mockStatusViewModelBuilder = MockLicenceStatusViewModelBuilder()
        mockStatusViewModelBuilder._stubbedViewModel = ValidityStatusViewModel(
            formattedStatus: "Mock licence status"
        )
        let mockAddress = "1 LEANDER DRIVE\nCASTLETON\nOL11 4AB"
        let mockDrivingLicence = DrivingLicence.arrange(driverFullAddress: mockAddress)

        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: mockStatusViewModelBuilder,
            openURLAction: { _, _ in },
            menuSelectionAction: { _ in },
            copyToClipboardAction: { _ in },
            analyticsService: MockAnalyticsService()
        )


        let expectedAccessibilityLabel = String.localizedStringWithFormat(
            String.dvla.localized("licenceAddressAccessibilityLabel"),
            "1 LEANDER DRIVE, CASTLETON, OL11 4AB"
        )
        #expect(sut.addressAccessibilityLabel == expectedAccessibilityLabel)
    }
    @Test
    func copyToClipboard_setsPasteboardAndTracksEvent() async throws {
        let mockPasteboard = MockPasteboard()
        let mockAnalytics = MockAnalyticsService()

        let mockDrivingLicence = DrivingLicence.arrange(licenceType: "Provisional")

        let mockStatusViewModelBuilder = MockLicenceStatusViewModelBuilder()
        mockStatusViewModelBuilder._stubbedViewModel = ValidityStatusViewModel(
            formattedStatus: "Mock licence status"
        )

        let sut = DrivingLicenceSummaryViewModel(
            drivingLicence: mockDrivingLicence,
            statusBuilder: mockStatusViewModelBuilder,
            openURLAction: { _, _ in },
            menuSelectionAction: { _ in },
            copyToClipboardAction: { _ in },
            analyticsService: mockAnalytics,
            pasteboard: mockPasteboard
        )

        sut.copyToClipboard()

        #expect(mockPasteboard.string == sut.licenceNumber)
        #expect(mockAnalytics._trackedEvents.count == 1)
    }
}

final class MockPasteboard: PasteboardInterface {
    var string: String?
}

