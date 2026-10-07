import Foundation
import Testing

@testable import govuk_ios

struct VehicleMenuItemsBuilderTests {
    let urls = DvlaURLs.arrange()

    // MARK: - Menu item combinations

    @Test
    func makeMenuItems_notTaxed_sorn_returnsExpectedItems() {
        let sut = VehicleMenuItemsBuilder(
            urls: urls,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let items = sut.makeMenuItems(
            sornStart: Date(),
            taxStatus: .untaxed
        )
        let expectedTitles = [
            String(localized: .DVLA.vehicleMenuSornRulesTitle),
            String(localized: .DVLA.vehicleMenuSoldVehicleTitle),
            String(localized: .DVLA.vehicleMenuGetLogbookTitle),
            String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle)
        ]
        #expect(items.map(\.title) == expectedTitles)
    }

    @Test
    func makeMenuItems_taxed_notSorn_returnsExpectedItems() {
        let sut = VehicleMenuItemsBuilder(
            urls: urls,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let items = sut.makeMenuItems(
            sornStart: nil,
            taxStatus: .taxed
        )
        let expectedTitles = [
            String(localized: .DVLA.vehicleMenuSoldVehicleTitle),
            String(localized: .DVLA.vehicleMenuMakeSornTitle),
            String(localized: .DVLA.vehicleMenuGetLogbookTitle),
            String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle),
            String(localized: .DVLA.vehicleMenuCancelTaxTitle)
        ]
        #expect(items.map(\.title) == expectedTitles)
    }

    @Test
    func makeMenuItems_taxed_sorn_returnsExpectedItems() {
        let sut = VehicleMenuItemsBuilder(
            urls: urls,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let items = sut.makeMenuItems(
            sornStart: Date(),
            taxStatus: .taxed
        )
        let expectedTitles = [
            String(localized: .DVLA.vehicleMenuSornRulesTitle),
            String(localized: .DVLA.vehicleMenuSoldVehicleTitle),
            String(localized: .DVLA.vehicleMenuGetLogbookTitle),
            String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle),
            String(localized: .DVLA.vehicleMenuCancelTaxTitle)
        ]
        #expect(items.map(\.title) == expectedTitles)
    }

    @Test
    func makeMenuItems_notTaxed_notSorn_returnsExpectedItems() {
        let sut = VehicleMenuItemsBuilder(
            urls: urls,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let items = sut.makeMenuItems(
            sornStart: nil,
            taxStatus: .untaxed
        )
        let expectedTitles = [
            String(localized: .DVLA.vehicleMenuSoldVehicleTitle),
            String(localized: .DVLA.vehicleMenuMakeSornTitle),
            String(localized: .DVLA.vehicleMenuGetLogbookTitle),
            String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle)
        ]
        #expect(items.map(\.title) == expectedTitles)
    }

    // MARK: - URL actions

    @Test
    func sornRules_openURLAction_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        await confirmation { confirmation in
            let sut = VehicleMenuItemsBuilder(
                urls: urls,
                analyticsService: mockAnalyticsService,
                openURLAction: { _ in confirmation() }
            )
            let items = sut.makeMenuItems(
                sornStart: Date(),
                taxStatus: .untaxed
            )
            items.first {
                $0.title == String(localized: .DVLA.vehicleMenuSornRulesTitle)
            }?.openURLAction("Title")
        }

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(
            (mockAnalyticsService._trackedEvents.first?.params!["url"]! as! String) ==
            urls.sornRules?.absoluteString
        )
    }

    @Test
    func soldVehicle_openURLAction_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        await confirmation { confirmation in
            let sut = VehicleMenuItemsBuilder(
                urls: urls,
                analyticsService: mockAnalyticsService,
                openURLAction: { _ in confirmation() }
            )
            let items = sut.makeMenuItems(
                sornStart: nil,
                taxStatus: .taxed
            )
            items.first {
                $0.title == String(localized: .DVLA.vehicleMenuSoldVehicleTitle)
            }?.openURLAction("Title")
        }

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(
            (mockAnalyticsService._trackedEvents.first?.params!["url"]! as! String) ==
            urls.soldVehicle?.absoluteString
        )
    }

    @Test
    func makeSorn_openURLAction_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        await confirmation { confirmation in
            let sut = VehicleMenuItemsBuilder(
                urls: urls,
                analyticsService: mockAnalyticsService,
                openURLAction: { _ in confirmation() }
            )
            let items = sut.makeMenuItems(
                sornStart: nil,
                taxStatus: .untaxed
            )
            items.first {
                $0.title == String(localized: .DVLA.vehicleMenuMakeSornTitle)
            }?.openURLAction("Title")
        }

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(
            (mockAnalyticsService._trackedEvents.first?.params!["url"]! as! String) ==
            urls.makeSorn?.absoluteString
        )
    }

    @Test
    func getLogbook_openURLAction_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        await confirmation { confirmation in
            let sut = VehicleMenuItemsBuilder(
                urls: urls,
                analyticsService: mockAnalyticsService,
                openURLAction: { _ in confirmation() }
            )
            let items = sut.makeMenuItems(
                sornStart: nil,
                taxStatus: .taxed
            )
            items.first {
                $0.title == String(localized: .DVLA.vehicleMenuGetLogbookTitle)
            }?.openURLAction("Title")
        }

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(
            (mockAnalyticsService._trackedEvents.first?.params!["url"]! as! String) ==
            urls.getLogbook?.absoluteString
        )
    }

    @Test
    func changeLogbookAddress_openURLAction_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        await confirmation { confirmation in
            let sut = VehicleMenuItemsBuilder(
                urls: urls,
                analyticsService: mockAnalyticsService,
                openURLAction: { _ in confirmation() }
            )
            let items = sut.makeMenuItems(
                sornStart: nil,
                taxStatus: .taxed
            )
            items.first {
                $0.title == String(localized: .DVLA.vehicleMenuChangeLogbookAddressTitle)
            }?.openURLAction("Title")
        }

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(
            (mockAnalyticsService._trackedEvents.first?.params!["url"]! as! String) ==
            urls.changeLogbookAddress?.absoluteString
        )
    }

    @Test
    func cancelTax_openURLAction_opensURLAndTracksEvent() async {
        let mockAnalyticsService = MockAnalyticsService()
        await confirmation { confirmation in
            let sut = VehicleMenuItemsBuilder(
                urls: urls,
                analyticsService: mockAnalyticsService,
                openURLAction: { _ in confirmation() }
            )
            let items = sut.makeMenuItems(
                sornStart: nil,
                taxStatus: .taxed
            )
            items.first {
                $0.title == String(localized: .DVLA.vehicleMenuCancelTaxTitle)
            }?.openURLAction("Title")
        }

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(
            (mockAnalyticsService._trackedEvents.first?.params!["url"]! as! String) ==
            urls.cancelTax?.absoluteString
        )
    }
}
