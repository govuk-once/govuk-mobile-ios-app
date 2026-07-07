import Foundation
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct LicenceStatusViewModelBuilderTests {
    @Test
    func makeViewModel_licenceExpired_validToDateIsNotNil_returnsExpectedResult() {
        let dvlaURLs: DvlaURLs = .arrange(renewLicence: "https://renewLicence.com")
        var receivedUrl: URL?
        let sut = LicenceStatusViewModelBuilder(urls: dvlaURLs)
        let result = sut.makeViewModel(
            status: .expired,
            validToDate: .arrange("01/01/2025"),
            openURLAction:  { url in
                receivedUrl = url
            }
        )
        let expectedStatus = String(localized: .DVLA.expiredOn(date: "1 January 2025"))
        let expectedAccessibilityLabel = String(localized: .DVLA.licenceStatusAccessibilityLabel(expectedStatus))
        #expect(result.title == nil)
        #expect(result.status == expectedStatus)
        #expect(result.statusAccessibilityLabel == expectedAccessibilityLabel)
        #expect(result.footer == String(localized: .DVLA.licenceStatusFooter))
        #expect(result.iconName == "exclamationmark.triangle.fill")
        #expect(result.iconTintColour == nil)
        #expect(result.buttonAction != nil)
        result.buttonAction?()
        #expect(receivedUrl == URL(string: "https://renewLicence.com"))
    }

    @Test
    func makeViewModel_licenceExpired_validToDateIsNil_returnsExpectedResult() {
        let dvlaURLs: DvlaURLs = .arrange(renewLicence: "https://renewLicence.com")
        let sut = LicenceStatusViewModelBuilder(urls: dvlaURLs)
        let result = sut.makeViewModel(
            status: .expired,
            validToDate: nil,
            openURLAction:  { _ in }
        )
        #expect(result.title == nil)
        #expect(result.status == String(localized: .DVLA.expired))
        #expect(result.footer == String(localized: .DVLA.licenceStatusFooter))
        #expect(result.iconName == "exclamationmark.triangle.fill")
        #expect(result.iconTintColour == nil)
        #expect(result.buttonTitle == String(localized: .DVLA.renewLicenceButtonTitle))
        #expect(result.buttonAction != nil)
    }

    @Test
    func makeViewModel_licenceValid_validToDateIsNotNil_returnsExpectedResult() {
        let sut = LicenceStatusViewModelBuilder(urls: .arrange)
        let result = sut.makeViewModel(
            status: .valid,
            validToDate: .arrange("01/01/2025"),
            openURLAction:  { _ in },
            currentDate: .arrange("01/08/2024"),
        )
        let expectedStatus = String(localized: .DVLA.validUntil(date: "1 January 2025"))
        let expectedAccessibilityLabel = String(localized: .DVLA.licenceStatusAccessibilityLabel(expectedStatus))
        #expect(result.title == nil)
        #expect(result.status == expectedStatus)
        #expect(result.statusAccessibilityLabel == expectedAccessibilityLabel)
        #expect(result.footer == nil)
        #expect(result.buttonTitle == nil)
        #expect(result.buttonAction == nil)
        #expect(result.iconName == "checkmark.circle.fill")
        #expect(result.iconTintColour == .govUK.fills.surfaceButtonPrimary)
    }

    @Test
    func makeViewModel_licenceValid_validToDateIsNil_returnsExpectedResult() {
        let sut = LicenceStatusViewModelBuilder(urls: .arrange)
        let result = sut.makeViewModel(
            status: .valid,
            validToDate: nil,
            openURLAction:  { _ in }
        )
        #expect(result.title == nil)
        #expect(result.status == String(localized: .DVLA.valid))
        #expect(result.footer == nil)
        #expect(result.buttonTitle == nil)
        #expect(result.buttonAction == nil)
        #expect(result.iconName == "checkmark.circle.fill")
        #expect(result.iconTintColour == .govUK.fills.surfaceButtonPrimary)
    }

    @Test
    func makeViewModel_licenceValid_expiringWithinCountdownWindow_returnsExpectedResult() {
        let sut = LicenceStatusViewModelBuilder(urls: .arrange)
        let result = sut.makeViewModel(
            status: .valid,
            validToDate: .arrange("01/01/2025"),
            openURLAction:  { _ in },
            currentDate: .arrange("15/12/2024")
        )
        let expectedStatus = String(localized: .DVLA.expiringOn(date: "1 January 2025"))
        let expectedAccessibilityLabel = String(localized: .DVLA.licenceStatusAccessibilityLabel(expectedStatus))
        #expect(result.title == nil)
        #expect(result.status == expectedStatus)
        #expect(result.statusAccessibilityLabel == expectedAccessibilityLabel)
        #expect(result.footer == String(localized: .DVLA.licenceStatusFooter))
        #expect(result.buttonTitle == String(localized: .DVLA.renewLicenceButtonTitle))
        #expect(result.buttonAction != nil)
        #expect(result.progressViewModel?.daysLeft == String(localized: .DVLA.daysLeft(days: 17)))
        #expect(result.iconName == nil)
    }

    @Test
    func makeViewModel_licenceStatusNotValidOrExpired_returnsUnknown() {
        let sut = LicenceStatusViewModelBuilder(urls: .arrange)
        let result = sut.makeViewModel(
            status: .disqualified,
            validToDate: nil,
            openURLAction:  { _ in }
        )
        #expect(result.title == nil)
        #expect(result.status == String(localized: .DVLA.unknown))
        #expect(result.footer == nil)
        #expect(result.buttonTitle == nil)
        #expect(result.buttonAction == nil)
        #expect(result.iconName == nil)
        #expect(result.iconTintColour == nil)
    }
}

