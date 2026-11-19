import Foundation
import Testing

@testable import govuk_ios

@Suite
struct LicenceCategoryGroupTests {

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
