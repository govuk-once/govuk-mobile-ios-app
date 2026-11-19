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
        let fullCar = makeEntitlement(code: "B", type: .full)
        let provisionalMotorcycle = makeEntitlement(code: "A", type: .provisional)

        let result = sut.map(entitlements: [fullCar, provisionalMotorcycle])

        #expect(result.entitledToDrive == [
            EntitlementGroup(group: .cars, entitlements: [fullCar])
        ])
        #expect(result.provisionallyEntitledToDrive == [
            EntitlementGroup(group: .motorcycles, entitlements: [provisionalMotorcycle])
        ])
    }

    // MARK: - Ordering (GOVUKAPP-4152)

    @Test
    func map_ordersGroupsAccordingToCatalogSpecificationRegardlessOfInputOrder() {
        let entitlements = [
            makeEntitlement(code: "n", type: .full),
            makeEntitlement(code: "D", type: .full),
            makeEntitlement(code: "D1", type: .full),
            makeEntitlement(code: "C", type: .full),
            makeEntitlement(code: "C1", type: .full),
            makeEntitlement(code: "B", type: .full),
            makeEntitlement(code: "B1", type: .full),
            makeEntitlement(code: "A", type: .full),
            makeEntitlement(code: "AM", type: .full)
        ]

        let result = sut.map(entitlements: entitlements)
        let groups = result.entitledToDrive.map(\.group)

        #expect(groups == [
            .mopeds,
            .motorcycles,
            .lightVehicles,
            .cars,
            .mediumSizedVehicles,
            .largeVehicles,
            .minibuses,
            .buses,
            .otherVehicles
        ])
    }

    @Test
    func map_ordersCodesWithinGroupAccordingToCatalogOrder() {
        let be = makeEntitlement(code: "BE", type: .full)
        let b = makeEntitlement(code: "B", type: .full)

        let result = sut.map(entitlements: [be, b])
        let carGroup = result.entitledToDrive.first

        #expect(carGroup?.group == .cars)
        #expect(carGroup?.entitlements == [b, be])
    }

    @Test
    func map_omitsGroupsWhenNoMatchingEntitlementsAreHeld() {
        let b = makeEntitlement(code: "B", type: .full)

        let result = sut.map(entitlements: [b])

        #expect(result.entitledToDrive.count == 1)
        #expect(result.entitledToDrive.first?.group == .cars)
        #expect(result.entitledToDrive.first?.id == .cars)
    }

    @Test
    func map_omitsUnrecognisedCategoryCodes() {
        let known = makeEntitlement(code: "B", type: .full)
        let unknown = makeEntitlement(code: "Z99", type: .full)

        let result = sut.map(entitlements: [known, unknown])

        #expect(result.entitledToDrive == [
            EntitlementGroup(group: .cars, entitlements: [known])
        ])
    }

    // MARK: - Case Insensitivity

    @Test
    func map_categoryCodeMatchingIsCaseInsensitive() {
        let lowercaseB = makeEntitlement(code: "b", type: .full)
        let lowercaseAM = makeEntitlement(code: "am", type: .full)

        let result = sut.map(entitlements: [lowercaseB, lowercaseAM])

        #expect(result.entitledToDrive == [
            EntitlementGroup(group: .mopeds, entitlements: [lowercaseAM]),
            EntitlementGroup(group: .cars, entitlements: [lowercaseB])
        ])
    }

    @Test(arguments: ["F", "f", "K", "k", "L", "l", "N", "n"])
    func map_forLowercaseCatalogCategories_matchesRegardlessOfInputCasing(inputCode: String) {
        let entitlement = makeEntitlement(code: inputCode, type: .full)

        let result = sut.map(entitlements: [entitlement])

        #expect(result.entitledToDrive == [
            EntitlementGroup(group: .otherVehicles, entitlements: [entitlement])
        ])
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
