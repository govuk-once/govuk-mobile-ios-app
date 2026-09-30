import Testing
import Foundation

@testable import govuk_ios
@testable import GovKit

@Suite
struct VehicleCheckResultViewModelTests {

    private var mockAnalyticsService = MockAnalyticsService()
    private var mockAppConfigService = MockAppConfigService()

    @Test
    func init_propertiesMapCorrectly() {
        let mockVehicle = VehicleEnquiryResponse.Vehicle.arrange(
            registrationNumber: "CA72 BNA",
            make: "FORD"
            )
        let sut = VehicleCheckResultViewModel(
            vehicle: mockVehicle,
            analyticsService: mockAnalyticsService,
            configService: mockAppConfigService,
            actions: .empty
            )
        #expect(sut.registrationNumber == "CA72 BNA")
        #expect(sut.make == "FORD")
    }

    @Test
    func specificationSection_containsExpectedRows() {
        let sut = VehicleCheckResultViewModel(
            vehicle: .arrange,
            analyticsService: mockAnalyticsService,
            configService: mockAppConfigService,
            actions: .empty
        )
        let section = sut.specificationSection
        #expect(section.rows.count == 6)

        let expectedRowIds = [
            "vehicle.make.row",
            "vehicle.yearOfFirstRegistration.row",
            "vehicle.fuelType.row",
            "vehicle.colour.row",
            "vehicle.engineSize.row",
            "vehicle.emissions.row"
        ]
        #expect(section.rows.map(\.id) == expectedRowIds)
    }

    @Test
    func menuItems_whenMotAndTaxBothValid_containsBaseMenuItemsOnly() {
        let mockVehicle = VehicleEnquiryResponse.Vehicle.arrange(
            taxStatus: .taxed,
            motStatus: "Valid"
            )
        let sut = VehicleCheckResultViewModel(
            vehicle: mockVehicle,
            analyticsService: mockAnalyticsService,
            configService: mockAppConfigService,
            actions: .empty
        )
        let menuItems = sut.menuItems
        #expect(menuItems.count == 3)
        #expect(menuItems[0].title == String(localized: .DVLA.vehicleMenuRegisterToYouTitle))
        #expect(menuItems[0].accessibilityLabel == String(localized: .DVLA.vehicleMenuRegisterToYouAccessibilityTitle))
        #expect(menuItems[1].title == String(localized: .DVLA.vehicleMenuUsedCarChecksTitle))
        #expect(menuItems[2].title == String(localized: .DVLA.vehicleMenuReportAbandonedTitle))
        #expect(menuItems[2].accessibilityLabel == String(localized: .DVLA.vehicleMenuReportAbandonedAccessibilityLabel))
    }

    @Test(arguments: [
        TaxStatus.untaxed,
        TaxStatus.sorn,
        TaxStatus.notTaxedForOnRoadUse
    ])
    func menuItems_whenMOTisValidAndVehicleIsNotTaxed_containsReportAsOnRoadMenuItem(taxStatus: TaxStatus) {
        let mockUrlString = "https://dvla.gov.uk/report-untaxed-vehicle"
        mockAppConfigService._dvlaUrls = .arrange(reportUntaxedVehicle: mockUrlString)
        var receivedUrl: URL?

        let mockVehicle = VehicleEnquiryResponse.Vehicle.arrange(
            taxStatus: taxStatus,
            motStatus: "Valid"
        )
        let sut = VehicleCheckResultViewModel(
            vehicle: mockVehicle,
            analyticsService: mockAnalyticsService,
            configService: mockAppConfigService,
            actions: .init(
                openURLAction: { url in
                    receivedUrl = url
                },
                searchAction: {},
                dismissAction: {}
            )
        )
        let menuItems = sut.menuItems
        #expect(menuItems.count == 4)
        #expect(menuItems[3].title == String(localized: .DVLA.vehicleMenuReportOnRoadTitle))
        #expect(menuItems[3].accessibilityLabel == String(localized: .DVLA.vehicleMenuReportOnRoadAccessibilityLabel))
        menuItems[3].openURLAction("report vehicle on road")
        #expect(receivedUrl?.absoluteString == mockUrlString)
    }

    @Test(arguments: [
        TaxStatus.taxed,
        TaxStatus.untaxed,
        TaxStatus.sorn,
        TaxStatus.notTaxedForOnRoadUse
    ])
    func menuItems_whenMOTisNotValid_containsReportAsOnRoadMenuItem(taxStatus: TaxStatus) {
        let mockUrlString = "https://dvla.gov.uk/report-no-mot"
        mockAppConfigService._dvlaUrls = .arrange(reportNoMot: mockUrlString)
        var receivedUrl: URL?

        let mockVehicle = VehicleEnquiryResponse.Vehicle.arrange(
            taxStatus: taxStatus,
            motStatus: "Not valid"
        )
        let sut = VehicleCheckResultViewModel(
            vehicle: mockVehicle,
            analyticsService: mockAnalyticsService,
            configService: mockAppConfigService,
            actions: .init(
                openURLAction: { url in
                    receivedUrl = url
                },
                searchAction: {},
                dismissAction: {}
            )
        )
        let menuItems = sut.menuItems
        #expect(menuItems.count == 4)
        #expect(menuItems[3].title == String(localized: .DVLA.vehicleMenuReportOnRoadTitle))
        #expect(menuItems[3].accessibilityLabel == String(localized: .DVLA.vehicleMenuReportOnRoadAccessibilityLabel))
        menuItems[3].openURLAction("report vehicle on road")
        #expect(receivedUrl?.absoluteString == mockUrlString)

    }

    @Test
    func openURLAction_tracksCorrectEvent() throws {
        let mockUrlString = "https://dvla.gov.uk/sold-vehicle"
        mockAppConfigService._dvlaUrls = .arrange(soldVehicle: mockUrlString)

        let sut = VehicleCheckResultViewModel(
            vehicle: .arrange,
            analyticsService: mockAnalyticsService,
            configService: mockAppConfigService,
            actions: .empty
        )
        sut.menuItems.first?.openURLAction("Register to you")
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["type"] as? String == "Button")
        #expect(trackedEvent.params?["text"] as? String == "Register to you")
        #expect(trackedEvent.params?["section"] as? String == "Driving")
        #expect(trackedEvent.params?["url"] as? String == mockUrlString)
    }

    @Test
    func searchAction_tracksCorrectEvent() throws {
        let sut = VehicleCheckResultViewModel(
            vehicle: .arrange,
            analyticsService: mockAnalyticsService,
            configService: mockAppConfigService,
            actions: .empty
        )
        sut.search()
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["type"] as? String == "Button")
        #expect(trackedEvent.params?["text"] as? String == "Search")
        #expect(trackedEvent.params?["section"] as? String == "Driving")
        #expect(trackedEvent.params?["action"] as? String == "Open search number plate")
        #expect(trackedEvent.params?["external"] as? Bool == false)
    }

    @Test
    func dismissAction_tracksCorrectEvent() throws {
        let sut = VehicleCheckResultViewModel(
            vehicle: .arrange,
            analyticsService: mockAnalyticsService,
            configService: mockAppConfigService,
            actions: .empty
        )
        sut.dismiss()
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["type"] as? String == "Button")
        #expect(trackedEvent.params?["text"] as? String == "Back")
        #expect(trackedEvent.params?["section"] as? String == "Driving")
    }
}

extension VehicleCheckResultActions {
    static var empty: VehicleCheckResultActions {
        .init(
            openURLAction: { _ in },
            searchAction: {},
            dismissAction: {}
        )
    }
}

