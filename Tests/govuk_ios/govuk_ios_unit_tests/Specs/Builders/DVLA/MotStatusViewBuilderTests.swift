import Foundation
import Testing
import GovKit
@testable import govuk_ios

@Suite
struct MOTStatusViewModelBuilderTests {

    private var testAnchorDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: "09/07/2026")!
    }

    private func generateFutureDate(daysAhead: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: daysAhead, to: testAnchorDate)!
    }

    @MainActor
    @Test
    func makeViewModel_motValid_moreThan28DaysLeft_returnsExpectedResult() {
        let expiryDate = generateFutureDate(daysAhead: 45)
        let vehicle = CustomerSummary.Vehicle.makeStub(motStatus: "Valid", motExpiryDate: expiryDate)
        let sut = MotStatusViewModelBuilder(urls: nil, analyticsService: MockAnalyticsService(), openURLAction: { _ in })
        let result = sut.makeViewModel_forTesting(vehicle: vehicle, currentDate: testAnchorDate)

        let expectedDateString = DateFormatter.dvlaAccount.string(from: expiryDate)
        let expectedStatus = String(localized: .DVLA.motValidUntil(expectedDateString))

        #expect(result.title == String(localized: .DVLA.motStatusTitle))
        #expect(result.formattedStatus == expectedStatus)
        #expect(result.iconName == "checkmark.circle.fill")
        #expect(result.iconTintColour == .govUK.fills.surfaceButtonPrimary)
    }

    @MainActor
    @Test
    func makeViewModel_motValid_expiringWithinCountdownWindow_returnsExpectedResult() {
        let expiryDate = generateFutureDate(daysAhead: 12)
        let vehicle = CustomerSummary.Vehicle.makeStub(motStatus: "Valid", motExpiryDate: expiryDate)
        let sut = MotStatusViewModelBuilder(urls: nil, analyticsService: MockAnalyticsService(), openURLAction: { _ in })

        let result = sut.makeViewModel_forTesting(vehicle: vehicle, currentDate: testAnchorDate)

        let expectedDateString = DateFormatter.dvlaAccount.string(from: expiryDate)
        let expectedStatus = String(localized: .DVLA.motExpiringOn(expectedDateString))

        #expect(result.title == String(localized: .DVLA.motStatusTitle))
        #expect(result.formattedStatus == expectedStatus)
        #expect(result.status as? MOTValidityStatus == .expiringSoon)
        #expect(result.progressViewModel != nil)
        #expect(result.footer == String(localized: .DVLA.motSyncDelayNotice))
    }

    @MainActor
    @Test
    func makeViewModel_motNotValid_returnsExpiredViewModel() {
        let expiryDate = generateFutureDate(daysAhead: -5)
        let vehicle = CustomerSummary.Vehicle.makeStub(motStatus: "Not valid", motExpiryDate: expiryDate)
        let sut = MotStatusViewModelBuilder(urls: nil, analyticsService: MockAnalyticsService(), openURLAction: { _ in })

        let result = sut.makeViewModel_forTesting(vehicle: vehicle, currentDate: testAnchorDate)

        let expectedDateString = DateFormatter.dvlaAccount.string(from: expiryDate)
        let expectedStatus = String(localized: .DVLA.motExpiredOn(expectedDateString))

        #expect(result.title == String(localized: .DVLA.motStatusTitle))
        #expect(result.formattedStatus == expectedStatus)
        #expect(result.iconName == "exclamationmark.triangle.fill")
        #expect(result.status as? MOTValidityStatus == .expired)
    }

    @MainActor
    @Test
    func makeViewModel_noResultsReturned_returnsButtonLinkToHistoricVehicles() {
        var openedUrl: URL?
        let vehicle = CustomerSummary.Vehicle.makeStub(motStatus: "No results returned")
        let sut = MotStatusViewModelBuilder(urls: nil, analyticsService: MockAnalyticsService(), openURLAction: { url in openedUrl = url })

        let result = sut.makeViewModel_forTesting(vehicle: vehicle, currentDate: testAnchorDate)

        #expect(result.formattedStatus == String(localized: .DVLA.motNoResultsReturned))
        #expect(result.buttonTitle == String(localized: .DVLA.motCheckIfItNeedsAnMOT))
        #expect(result.status as? MOTValidityStatus == .noResultsReturned)

        result.buttonAction?()
        #expect(openedUrl == Constants.API.defaultDvlaNoResultsUrl)
    }
}

extension MotStatusViewModelBuilder {
    @MainActor
    func makeViewModel_forTesting(vehicle: CustomerSummary.Vehicle, currentDate: Date) -> ValidityStatusViewModel {
        return self.makeViewModel(vehicle: vehicle)
    }
}

extension CustomerSummary.Vehicle {
    static func makeStub(
        registrationNumber: String = "LL09RNZ",
        motStatus: String = "Valid",
        motExpiryDate: Date? = nil,
        taxStatus: TaxStatus? = .taxed,
        sornStart: Date? = nil
    ) -> Self {
        return .init(
            vehicleId: 12345,
            registrationNumber: registrationNumber,
            make: "Vauxhall",
            model: "Astra",
            taxStatus: taxStatus,
            taxedUntil: nil,
            motStatus: motStatus,
            motExpiryDate: motExpiryDate,
            dateOfFirstRegistration: Date(),
            colour: "Black",
            secondaryColour: nil,
            fuelType: .petrol,
            exhaustEmissions: nil,
            engineCapacity: 1600,
            keeper: nil,
            sornStart: sornStart,
            currentLicence: nil
        )
    }
}


