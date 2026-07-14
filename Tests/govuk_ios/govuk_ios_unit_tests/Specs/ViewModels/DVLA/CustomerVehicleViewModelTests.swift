import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@MainActor
struct CustomerVehicleViewModelTests {
    @Test
    func initWithVehicle_mapsPropertiesCorrectly() {
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            registrationNumber: "AB12 CDE",
            make: "FORD",
            model: "FOCUS"
        )
        let sut = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailAction: {},
            openURLAction: { _ in },
            configService: MockAppConfigService(),
            analyticsService: MockAnalyticsService()
        )
        #expect(sut.vehicleMake == "FORD")
        #expect(sut.vehicleModel == "FOCUS")
        #expect(sut.registrationNumber == "AB12 CDE")
    }

    @Test
    func vehicleModel_modelIsNil_returnsUnknown() {
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            registrationNumber: "AB12 CDE",
            make: "FORD",
            model: nil
        )
        let sut = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailAction: {},
            openURLAction: { _ in },
            configService: MockAppConfigService(),
            analyticsService: MockAnalyticsService()
        )
        #expect(sut.vehicleModel == String.dvla.localized("unknown"))
    }

    @Test
    func taxStatusViewModel_taxedUntilDateIsValid_formatsStatusCorrectly() {
        let futureDate = generateFutureDate(daysAhead: 45)
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            taxedUntil: futureDate
        )
        let sut = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailAction: {},
            openURLAction: { _ in },
            configService: MockAppConfigService(),
            analyticsService: MockAnalyticsService()
        )

        let expectedDateString = DateFormatter.dvlaAccount.string(from: futureDate)
        let expectedStatusString = "Valid until \(expectedDateString)"

        #expect(sut.taxStatusViewModel.title == String.dvla.localized("taxStatusTitle"))
        #expect(sut.taxStatusViewModel.formattedStatus == expectedStatusString)
    }

    @Test
    func taxStatusViewModel_taxedUntilDateIsNil_returnsUnknown() {
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            taxedUntil: nil
        )
        let sut = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailAction: {},
            openURLAction: { _ in },
            configService: MockAppConfigService(),
            analyticsService: MockAnalyticsService()
        )
        #expect(sut.taxStatusViewModel.formattedStatus == String(localized: .DVLA.valid))
    }

    @Test
    func motStatusViewModel_motExpiryDateIsValid_formatsStatusCorrectly() {
        let futureDate = generateFutureDate(daysAhead: 45)
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            motStatus: "Valid", motExpiryDate: futureDate
        )
        let sut = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailAction: {},
            openURLAction: { _ in },
            configService: MockAppConfigService(),
            analyticsService: MockAnalyticsService()
        )
        let expectedDate = futureDate
        let expectedDateString = DateFormatter.dvlaAccount.string(from: expectedDate)
        let expectedStatusString =
        String(localized: .DVLA.validUntil(date: expectedDateString))
        #expect(sut.motStatusViewModel.title ==
                String(localized: .DVLA.motStatusTitle))
        #expect(sut.motStatusViewModel.formattedStatus == expectedStatusString)
    }

    @Test
    func motStatusViewModel_motExpiryDateIsNil_returnsUnknown() {
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            motStatus: "Unknown",
            motExpiryDate: nil
        )
        let sut = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailAction: {},
            openURLAction: { _ in },
            configService: MockAppConfigService(),
            analyticsService: MockAnalyticsService()
        )

        #expect(sut.motStatusViewModel.formattedStatus == String(localized: .DVLA.motUnknown))
    }

    @Test
    func menuItems_notTaxed_sorn_returnsExpectedMenuItems() {
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            taxStatus: .untaxed,
            sornStart: Date()
        )
        let sut = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailAction: {},
            openURLAction: { _ in },
            configService: MockAppConfigService(),
            analyticsService: MockAnalyticsService()
        )
        let expectedMenuTitles = [
            String(localized: .DVLA.vehicleMenuSornRulesTitle),
            String(localized: .DVLA.vehicleMenuSoldVehicleTitle),
            String(localized: .DVLA.vehicleMenuGetLogbookTitle),
            String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle)
        ]
        #expect(sut.menuItems.map(\.title) == expectedMenuTitles)
    }

    @Test
    func menuItems_taxed_notSorn_returnsExpectedMenuItems() {
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            taxStatus: .taxed,
            sornStart: nil
        )
        let sut = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailAction: {},
            openURLAction: { _ in },
            configService: MockAppConfigService(),
            analyticsService: MockAnalyticsService()
        )
        let expectedMenuTitles = [
            String(localized: .DVLA.vehicleMenuSoldVehicleTitle),
            String(localized: .DVLA.vehicleMenuMakeSornTitle),
            String(localized: .DVLA.vehicleMenuGetLogbookTitle),
            String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle),
            String(localized: .DVLA.vehicleMenuCancelTaxTitle),
        ]

        #expect(sut.menuItems.map(\.title) == expectedMenuTitles)
    }

    @Test
    func menuItems_notTaxed_notSorn_returnsMenuItems() {
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            taxStatus: .untaxed,
            sornStart: nil
        )
        let sut = VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailAction: {},
            openURLAction: { _ in },
            configService: MockAppConfigService(),
            analyticsService: MockAnalyticsService()
        )
        let expectedMenuTitles = [
            String(localized: .DVLA.vehicleMenuSoldVehicleTitle),
            String(localized: .DVLA.vehicleMenuMakeSornTitle),
            String(localized: .DVLA.vehicleMenuGetLogbookTitle),
            String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle),
        ]

        #expect(sut.menuItems.map(\.title) == expectedMenuTitles)
    }

    @Test
    func menuItems_sornRules_openURLAction_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        let mockConfigService = MockAppConfigService()
        let dvlaURLs = DvlaURLs.arrange
        mockConfigService._dvlaUrls = dvlaURLs
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            taxStatus: .untaxed,
            sornStart: Date()
        )
        await confirmation { confirmation in
            let sut = VehicleSummaryViewModel(
                vehicle: mockVehicle,
                detailAction: {},
                openURLAction: { _ in confirmation() },
                configService: mockConfigService,
                analyticsService: mockAnalyticsService
            )
            sut.menuItems.first {
                $0.title == String(localized: .DVLA.vehicleMenuSornRulesTitle)
            }?.openURLAction("Title")
        }

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(
            (mockAnalyticsService._trackedEvents.first?.params!["url"]! as! String) ==
            dvlaURLs.sornRules?.absoluteString
        )
    }

    @Test
    func menuItems_soldVehicle_openURLAction_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        let mockConfigService = MockAppConfigService()
        let dvlaURLs = DvlaURLs.arrange
        mockConfigService._dvlaUrls = dvlaURLs
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            taxStatus: .taxed,
            sornStart: nil
        )
        await confirmation { confirmation in
            let sut = VehicleSummaryViewModel(
                vehicle: mockVehicle,
                detailAction: {},
                openURLAction: { _ in confirmation() },
                configService: mockConfigService,
                analyticsService: mockAnalyticsService
            )
            sut.menuItems.first {
                $0.title == String(localized: .DVLA.vehicleMenuSoldVehicleTitle)
            }?.openURLAction("Title")
        }

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(
            (mockAnalyticsService._trackedEvents.first?.params!["url"]! as! String) ==
            dvlaURLs.soldVehicle?.absoluteString
        )
    }

    @Test
    func menuItems_makeSorn_openURLAction_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        let mockConfigService = MockAppConfigService()
        let dvlaURLs = DvlaURLs.arrange
        mockConfigService._dvlaUrls = dvlaURLs
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            taxStatus: .untaxed,
            sornStart: nil
        )
        await confirmation { confirmation in
            let sut = VehicleSummaryViewModel(
                vehicle: mockVehicle,
                detailAction: {},
                openURLAction: { _ in confirmation() },
                configService: mockConfigService,
                analyticsService: mockAnalyticsService
            )
            sut.menuItems.first {
                $0.title == String(localized: .DVLA.vehicleMenuMakeSornTitle)
            }?.openURLAction("Title")
        }

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(
            (mockAnalyticsService._trackedEvents.first?.params!["url"]! as! String) ==
            dvlaURLs.makeSorn?.absoluteString
        )
    }

    @Test
    func menuItems_getLogbook_openURLAction_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        let mockConfigService = MockAppConfigService()
        let dvlaURLs = DvlaURLs.arrange
        mockConfigService._dvlaUrls = dvlaURLs
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            taxStatus: .taxed,
            sornStart: nil
        )
        await confirmation { confirmation in
            let sut = VehicleSummaryViewModel(
                vehicle: mockVehicle,
                detailAction: {},
                openURLAction: { _ in confirmation() },
                configService: mockConfigService,
                analyticsService: mockAnalyticsService
            )
            sut.menuItems.first {
                $0.title == String(localized: .DVLA.vehicleMenuGetLogbookTitle)
            }?.openURLAction("Title")
        }

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(
            (mockAnalyticsService._trackedEvents.first?.params!["url"]! as! String) ==
            dvlaURLs.getLogbook?.absoluteString
        )
    }

    @Test
    func menuItems_changeLogbookAddress_openURLAction_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        let mockConfigService = MockAppConfigService()
        let dvlaURLs = DvlaURLs.arrange
        mockConfigService._dvlaUrls = dvlaURLs
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            taxStatus: .taxed,
            sornStart: nil
        )
        await confirmation { confirmation in
            let sut = VehicleSummaryViewModel(
                vehicle: mockVehicle,
                detailAction: {},
                openURLAction: { _ in confirmation() },
                configService: mockConfigService,
                analyticsService: mockAnalyticsService
            )
            sut.menuItems.first {
                $0.title == String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle)
            }?.openURLAction("Title")
        }

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(
            (mockAnalyticsService._trackedEvents.first?.params!["url"]! as! String) ==
            dvlaURLs.changeLogbookAddress?.absoluteString
        )
    }

    @Test
    func menuItems_cancelTax_openURLAction_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        let mockConfigService = MockAppConfigService()
        let dvlaURLs = DvlaURLs.arrange
        mockConfigService._dvlaUrls = dvlaURLs
        let mockVehicle = CustomerVehicles.Vehicle.arrange(
            taxStatus: .taxed,
            sornStart: nil
        )
        await confirmation { confirmation in
            let sut = VehicleSummaryViewModel(
                vehicle: mockVehicle,
                detailAction: {},
                openURLAction: { _ in confirmation() },
                configService: mockConfigService,
                analyticsService: mockAnalyticsService
            )
            sut.menuItems.first {
                $0.title == String(localized: .DVLA.vehicleMenuCancelTaxTitle)
            }?.openURLAction("Title")
        }

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(
            (mockAnalyticsService._trackedEvents.first?.params!["url"]! as! String) ==
            dvlaURLs.cancelTax?.absoluteString
        )
    }

    private func generateFutureDate(daysAhead: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: daysAhead, to: Date.now)!
    }

}
