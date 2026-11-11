import Foundation
import Testing

@testable import govuk_ios

@Suite
struct EntitlementMapperTests {

    private let sut = EntitlementMapper()

    // MARK: - Empty States

    @Test
    func map_withEmptyEntitlements_returnsEmptyCollections() {
        let result = sut.map(entitlements: [])

        #expect(result.entitledToDrive.isEmpty)
        #expect(result.provisionallyEntitledToDrive.isEmpty)
    }

    // MARK: - Category Type Splitting

    @Test
    func map_splitsFullAndProvisionalEntitlementsCorrectly() {
        let entitlements = [
            makeEntitlement(code: "B", type: .full),
            makeEntitlement(code: "A", type: .provisional)
        ]

        let result = sut.map(entitlements: entitlements)

        #expect(result.entitledToDrive.count == 1)
        #expect(result.entitledToDrive.first?.title == LicenceCategoryGroup.cars.title)
        #expect(result.entitledToDrive.first?.codesDisplay == "B")

        #expect(result.provisionallyEntitledToDrive.count == 1)
        #expect(result.provisionallyEntitledToDrive.first?.title == LicenceCategoryGroup.motorcycles.title)
        #expect(result.provisionallyEntitledToDrive.first?.codesDisplay == "A")
    }

    // MARK: - Ordering (GOVUKAPP-4152)

    @Test
    func map_ordersGroupsAccordingToCatalogSpecificationRegardlessOfInputOrder() {
        let entitlements = [
            makeEntitlement(code: "f", type: .full),
            makeEntitlement(code: "B", type: .full),
            makeEntitlement(code: "AM", type: .full)
        ]

        let result = sut.map(entitlements: entitlements)
        let rowTitles = result.entitledToDrive.map(\.title)

        let expectedTitles = [
            LicenceCategoryGroup.mopeds.title,
            LicenceCategoryGroup.cars.title,
            LicenceCategoryGroup.otherVehicles.title
        ]

        #expect(rowTitles == expectedTitles)
    }

    @Test
    func map_ordersCodesWithinGroupAccordingToCatalogOrder() {
        let entitlements = [
            makeEntitlement(code: "BE", type: .full),
            makeEntitlement(code: "B", type: .full)
        ]

        let result = sut.map(entitlements: entitlements)
        let carRow = result.entitledToDrive.first

        #expect(carRow?.codesDisplay == "B, BE")
    }

    @Test
    func map_omitsGroupsWhenNoMatchingEntitlementsAreHeld() {
        let entitlements = [
            makeEntitlement(code: "B", type: .full)
        ]

        let result = sut.map(entitlements: entitlements)

        #expect(result.entitledToDrive.count == 1)
        #expect(result.entitledToDrive.first?.title == LicenceCategoryGroup.cars.title)
    }

    // MARK: - Case Insensitivity

    @Test
    func map_categoryCodeMatchingIsCaseInsensitive() {
        let entitlements = [
            makeEntitlement(code: "b", type: .full),
            makeEntitlement(code: "am", type: .full)
        ]

        let result = sut.map(entitlements: entitlements)

        #expect(result.entitledToDrive.count == 2)
        #expect(result.entitledToDrive[0].codesDisplay == "AM")
        #expect(result.entitledToDrive[1].codesDisplay == "B")
    }

    // MARK: - Special Lowercase Categories

    @Test(
        arguments: [
            ("F", "f"),
            ("K", "k"),
            ("L", "l"),
            ("N", "n")
        ]
    )
    func map_forSpecialLowercaseCategories_retainsCatalogLowercaseCasing(
        inputCode: String,
        expectedDisplayCode: String
    ) {
        let entitlements = [
            makeEntitlement(code: inputCode, type: .full)
        ]

        let result = sut.map(entitlements: entitlements)
        let otherRow = result.entitledToDrive.first

        #expect(otherRow?.title == LicenceCategoryGroup.otherVehicles.title)
        #expect(otherRow?.codesDisplay == expectedDisplayCode)
    }

    // MARK: - Helpers

    private func makeEntitlement(
        code: String,
        type: CategoryType,
        fromDate: Date = Date(),
        expiryDate: Date = Date()
    ) -> Entitlement {
        Entitlement(
            categoryCode: code,
            categoryLegalLiteral: "Category \(code)",
            categoryType: type,
            fromDate: fromDate,
            expiryDate: expiryDate,
            restrictions: []
        )
    }
}
