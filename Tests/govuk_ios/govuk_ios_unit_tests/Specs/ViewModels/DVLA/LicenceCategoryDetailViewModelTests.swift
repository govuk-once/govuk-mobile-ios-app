import Foundation
import Testing

@testable import govuk_ios

struct LicenceCategoryDetailViewModelTests {
    @Test
    func categoryProperties_mapCorrectly() {
        let mockEntitlement = Entitlement.arrange(
            categoryCode: "B",
            categoryLegalLiteral: "mock category legal literal",
            categoryType: .full,
            fromDate: .arrange("01/01/1995"),
            expiryDate: .arrange("02/02/2040"),
            restrictions: []
        )
        let sut = LicenceCategoryDetailViewModel(
            entitlement: mockEntitlement,
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        #expect(sut.categoryGroupTitle == String(localized: .DVLA.categoryGroupCars))
        #expect(sut.categoryIcon == ImageResource.drivingCategoryB)
        #expect(sut.categoryCode == "B")
        #expect(sut.validFrom == "1 January 1995")
        #expect(sut.validTo == "2 February 2040")
        #expect(sut.categoryDescription == "mock category legal literal")
    }

    @Test
    func restrictionRows_mapCorrectly() throws {
        let mockRestriction1 = EntitlementRestriction.arrange(restrictionCode: "01", restrictionLiteral: "mock restriction 1")
        let mockRestriction2 = EntitlementRestriction.arrange(restrictionCode: "02", restrictionLiteral: "mock restriction 2")

        let mockEntitlement = Entitlement.arrange(
            restrictions: [mockRestriction1, mockRestriction2]
        )
        let sut = LicenceCategoryDetailViewModel(
            entitlement: mockEntitlement,
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        #expect(sut.restrictionRows.count == 2)
        let firstRestrictionRow = try #require(sut.restrictionRows.first)
        #expect(firstRestrictionRow.code == "01")
        #expect(firstRestrictionRow.description == "mock restriction 1")
    }

    @Test
    func dismiss_tracksDismissEvent() throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = LicenceCategoryDetailViewModel(
            entitlement: .arrange,
            analyticsService: mockAnalyticsService,
            dismissAction: {}
        )
        sut.dismiss()
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["type"] as? String == "Button")
        #expect(trackedEvent.params?["text"] as? String == "Back")
        #expect(trackedEvent.params?["section"] as? String == "Driving")
    }

}
