import Foundation
import Testing
import GovKit
@testable import govuk_ios

@Suite
struct MOTStatusViewModelBuilderTests {
    let dateFormatter = DateFormatter.dvlaAccount

    @MainActor
    @Test
    func makeViewModel_motValid_moreThan28DaysLeft_returnsExpectedResult() {
        let expiryDate = generateFutureDate(daysAhead: 45)
        let vehicle = MotStatusVehicle(
            motStatus: "Valid",
            motExpiryDate: expiryDate,
            registrationNumber: "LG04 NBF"
        )
        let sut = MotStatusViewModelBuilder(
            urls: nil,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let result = sut.makeViewModel(vehicle: vehicle)

        #expect(result.title == String(localized: .DVLA.motStatusTitle))
        #expect(result.formattedStatus == String(
            localized: .DVLA.motValidUntil(dateFormatter.string(from: expiryDate)))
        )
        #expect(result.iconName == "checkmark.circle.fill")
        #expect(result.iconTintColour == .govUK.fills.surfaceButtonPrimary)
    }

    @MainActor
    @Test
    func makeViewModel_motValid_expiringWithinCountdownWindow_returnsExpectedResult() {
        let expiryDate = generateFutureDate(daysAhead: 12)
        let vehicle = MotStatusVehicle(
            motStatus: "Valid",
            motExpiryDate: expiryDate,
            registrationNumber: "LG04 NBF"
        )
        let sut = MotStatusViewModelBuilder(
            urls: nil,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )

        let result = sut.makeViewModel(vehicle: vehicle)

        #expect(result.title == String(localized: .DVLA.motStatusTitle))
        #expect(result.formattedStatus == String(
            localized: .DVLA.motExpiringOn(dateFormatter.string(from: expiryDate)))
        )
        #expect(result.status as? MOTValidityStatus == .expiringSoon)
        #expect(result.progressViewModel != nil)
        #expect(result.footer == String(localized: .DVLA.motSyncDelayNotice))
    }

    @MainActor
    @Test
    func makeViewModel_motNotValid_returnsExpiredViewModel() {
        let expiryDate = generateFutureDate(daysAhead: -5)
        let vehicle = MotStatusVehicle(
            motStatus: "Not valid",
            motExpiryDate: expiryDate,
            registrationNumber: "LG04 NBF"
        )
        let sut = MotStatusViewModelBuilder(
            urls: nil,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )

        let result = sut.makeViewModel(vehicle: vehicle)

        #expect(result.title == String(localized: .DVLA.motStatusTitle))
        #expect(result.formattedStatus == String(
            localized: .DVLA.motExpiredOn(dateFormatter.string(from: expiryDate)))
        )
        #expect(result.iconName == "exclamationmark.triangle.fill")
        #expect(result.status as? MOTValidityStatus == .expired)
    }

    @MainActor
    @Test
    func makeViewModel_noResultsReturned_returnsButtonLinkToHistoricVehicles() {
        var openedUrl: URL?
        let vehicle = MotStatusVehicle(
            motStatus: "No results returned",
            motExpiryDate: nil,
            registrationNumber: "LG04 NBF"
        )
        let sut = MotStatusViewModelBuilder(
            urls: nil,
            analyticsService: MockAnalyticsService(),
            openURLAction: { url in openedUrl = url }
        )
        let result = sut.makeViewModel(vehicle: vehicle)

        #expect(result.formattedStatus == "")
        #expect(result.buttonTitle == String(localized: .DVLA.motCheckIfItNeedsAnMOT))
        #expect(result.status as? MOTValidityStatus == .noResultsReturned)

        result.buttonAction?()
        #expect(openedUrl == Constants.API.defaultDvlaNoResultsUrl)
    }

    private func generateFutureDate(daysAhead: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: daysAhead, to: Date())!
    }

    @MainActor
    @Test
    func makeViewModel_motStatusValidButExpiryDateIsInPast_returnsExpiredViewModel() {
        let pastExpiryDate = generateFutureDate(daysAhead: -5)
        let vehicle = MotStatusVehicle(
            motStatus: "Valid",
            motExpiryDate: pastExpiryDate,
            registrationNumber: "LG04 NBF"
        )
        let sut = MotStatusViewModelBuilder(
            urls: nil,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let result = sut.makeViewModel(vehicle: vehicle)
        #expect(result.title == String(localized: .DVLA.motStatusTitle))
        #expect(result.formattedStatus == String(
            localized: .DVLA.motExpiredOn(dateFormatter.string(from: pastExpiryDate)))
        )
        #expect(result.iconName == "exclamationmark.triangle.fill")
        #expect(result.status as? MOTValidityStatus == .expired)
    }

}
