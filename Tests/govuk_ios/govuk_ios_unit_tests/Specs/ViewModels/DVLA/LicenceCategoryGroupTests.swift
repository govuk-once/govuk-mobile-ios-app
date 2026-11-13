import Foundation
import Testing

@testable import govuk_ios

@Suite
struct LicenceCategoryGroupTests {

    // MARK: - Category Code Grouping

    @Test(
        arguments: [
            ("P", LicenceCategoryGroup.mopeds),
            ("AM", LicenceCategoryGroup.mopeds),
            ("Q", LicenceCategoryGroup.mopeds),
            ("A", LicenceCategoryGroup.motorcycles),
            ("A1", LicenceCategoryGroup.motorcycles),
            ("A2", LicenceCategoryGroup.motorcycles),
            ("B1", LicenceCategoryGroup.lightVehicles),
            ("B", LicenceCategoryGroup.cars),
            ("BE", LicenceCategoryGroup.cars),
            ("C1", LicenceCategoryGroup.mediumSizedVehicles),
            ("C1E", LicenceCategoryGroup.mediumSizedVehicles),
            ("C", LicenceCategoryGroup.largeVehicles),
            ("CE", LicenceCategoryGroup.largeVehicles),
            ("D1", LicenceCategoryGroup.minibuses),
            ("D1E", LicenceCategoryGroup.minibuses),
            ("D", LicenceCategoryGroup.buses),
            ("DE", LicenceCategoryGroup.buses),
            ("F", LicenceCategoryGroup.otherVehicles),
            ("G", LicenceCategoryGroup.otherVehicles),
            ("H", LicenceCategoryGroup.otherVehicles),
            ("K", LicenceCategoryGroup.otherVehicles),
            ("L", LicenceCategoryGroup.otherVehicles),
            ("M", LicenceCategoryGroup.otherVehicles),
            ("N", LicenceCategoryGroup.otherVehicles)
        ]
    )
    func group_forValidCategoryCode_returnsExpectedGroup(
        code: String,
        expectedGroup: LicenceCategoryGroup
    ) {
        let result = LicenceCategoryGroup.group(for: code)

        #expect(result == expectedGroup)
    }

    // MARK: - Case Insensitivity

    @Test(
        arguments: [
            ("p", LicenceCategoryGroup.mopeds),
            ("am", LicenceCategoryGroup.mopeds),
            ("a1", LicenceCategoryGroup.motorcycles),
            ("b1", LicenceCategoryGroup.lightVehicles),
            ("be", LicenceCategoryGroup.cars),
            ("c1e", LicenceCategoryGroup.mediumSizedVehicles),
            ("ce", LicenceCategoryGroup.largeVehicles),
            ("d1e", LicenceCategoryGroup.minibuses),
            ("de", LicenceCategoryGroup.buses),
            ("f", LicenceCategoryGroup.otherVehicles)
        ]
    )
    func group_withLowercaseCode_matchesCaseInsensitively(
        code: String,
        expectedGroup: LicenceCategoryGroup
    ) {
        let result = LicenceCategoryGroup.group(for: code)

        #expect(result == expectedGroup)
    }

    // MARK: - Unknown & Invalid Codes

    @Test(
        arguments: [
            "",
            " ",
            "Z",
            "B2",
            "123",
            " B "
        ]
    )
    func group_forUnknownOrInvalidCode_returnsNil(code: String) {
        let result = LicenceCategoryGroup.group(for: code)

        #expect(result == nil)
    }

    // MARK: - Localized Titles

    @Test(
        arguments: [
            (LicenceCategoryGroup.mopeds, String(localized: .DVLA.categoryGroupMopeds)),
            (LicenceCategoryGroup.motorcycles, String(localized: .DVLA.categoryGroupMotorcycles)),
            (LicenceCategoryGroup.lightVehicles, String(localized: .DVLA.categoryGroupLightVehicles)),
            (LicenceCategoryGroup.cars, String(localized: .DVLA.categoryGroupCars)),
            (LicenceCategoryGroup.mediumSizedVehicles, String(localized: .DVLA.categoryGroupMediumSizedVehicles)),
            (LicenceCategoryGroup.largeVehicles, String(localized: .DVLA.categoryGroupLargeVehicles)),
            (LicenceCategoryGroup.minibuses, String(localized: .DVLA.categoryGroupMinibuses)),
            (LicenceCategoryGroup.buses, String(localized: .DVLA.categoryGroupBuses)),
            (LicenceCategoryGroup.otherVehicles, String(localized: .DVLA.categoryGroupOtherVehicles))
        ]
    )
    func title_returnsExpectedLocalizedString(
        group: LicenceCategoryGroup,
        expectedTitle: String
    ) {
        #expect(group.title == expectedTitle)
    }
}
