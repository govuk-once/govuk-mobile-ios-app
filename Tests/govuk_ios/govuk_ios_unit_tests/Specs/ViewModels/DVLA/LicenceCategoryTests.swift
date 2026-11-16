import Foundation
import Testing

@testable import govuk_ios

@Suite
struct LicenceCategoryTests {

    // MARK: - Initialization & Case Insensitivity

    @Test(
        arguments: [
            ("b", LicenceCategory.b),
            ("B", LicenceCategory.b),
            ("AM", LicenceCategory.am),
            ("am", LicenceCategory.am),
            ("c1e", LicenceCategory.c1e),
            ("f", LicenceCategory.f)
        ]
    )
    func init_withCode_isCaseInsensitiveAndAccurate(
        inputCode: String,
        expectedCategory: LicenceCategory
    ) {
        let category = LicenceCategory(code: inputCode)
        #expect(category == expectedCategory)
    }

    @Test
    func init_withInvalidCode_returnsNil() {
        #expect(LicenceCategory(code: "INVALID") == nil)
        #expect(LicenceCategory(code: "") == nil)
    }

    // MARK: - Group Mapping

    @Test(
        arguments: [
            (LicenceCategory.b, LicenceCategoryGroup.cars),
            (LicenceCategory.am, LicenceCategoryGroup.mopeds),
            (LicenceCategory.a, LicenceCategoryGroup.motorcycles),
            (LicenceCategory.f, LicenceCategoryGroup.otherVehicles)
        ]
    )
    func group_mapsToCorrectVehicleGroup(
        category: LicenceCategory,
        expectedGroup: LicenceCategoryGroup
    ) {
        #expect(category.group == expectedGroup)
    }

    // MARK: - Display Name Formatting

    @Test(
        arguments: [
            (LicenceCategory.b, "B"),
            (LicenceCategory.c1e, "C1E"),
            (LicenceCategory.f, "f"),
            (LicenceCategory.k, "k"),
            (LicenceCategory.l, "l")
        ]
    )
    func displayName_returnsExpectedCasing(
        category: LicenceCategory,
        expectedDisplayName: String
    ) {
        #expect(category.displayName == expectedDisplayName)
    }
}
