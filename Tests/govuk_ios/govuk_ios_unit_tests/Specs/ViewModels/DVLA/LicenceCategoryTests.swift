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

    @Test(
        arguments: [
            ("AM", LicenceCategory.am),
            ("P", LicenceCategory.p),
            ("Q", LicenceCategory.q),
            ("A1", LicenceCategory.a1),
            ("A2", LicenceCategory.a2),
            ("A", LicenceCategory.a),
            ("B1", LicenceCategory.b1),
            ("B", LicenceCategory.b),
            ("BE", LicenceCategory.be),
            ("C1", LicenceCategory.c1),
            ("C1E", LicenceCategory.c1e),
            ("C", LicenceCategory.c),
            ("CE", LicenceCategory.ce),
            ("D1", LicenceCategory.d1),
            ("D1E", LicenceCategory.d1e),
            ("D", LicenceCategory.d),
            ("DE", LicenceCategory.de),
            ("F", LicenceCategory.f),
            ("G", LicenceCategory.g),
            ("H", LicenceCategory.h),
            ("K", LicenceCategory.k),
            ("L", LicenceCategory.l),
            ("M", LicenceCategory.m),
            ("N", LicenceCategory.n)
        ]
    )
    func init_forValidCode_returnsExpectedCategory(
        code: String,
        expectedCategory: LicenceCategory
    ) {
        let result = LicenceCategory(code: code)

        #expect(result == expectedCategory)
    }

    @Test(
        arguments: [
            ("p", LicenceCategory.p),
            ("am", LicenceCategory.am),
            ("a1", LicenceCategory.a1),
            ("b1", LicenceCategory.b1),
            ("be", LicenceCategory.be),
            ("c1e", LicenceCategory.c1e),
            ("ce", LicenceCategory.ce),
            ("d1e", LicenceCategory.d1e),
            ("de", LicenceCategory.de),
            ("f", LicenceCategory.f),
            ("Be", LicenceCategory.be)
        ]
    )
    func init_withLowercaseOrMixedCaseCode_matchesCaseInsensitively(
        code: String,
        expectedCategory: LicenceCategory
    ) {
        let result = LicenceCategory(code: code)

        #expect(result == expectedCategory)
    }

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
    func init_forUnknownOrInvalidCode_returnsNil(code: String) {
        let result = LicenceCategory(code: code)

        #expect(result == nil)
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

    // MARK: - Category Grouping

    @Test(
        arguments: [
            (LicenceCategory.am, LicenceCategoryGroup.mopeds),
            (LicenceCategory.p, LicenceCategoryGroup.mopeds),
            (LicenceCategory.q, LicenceCategoryGroup.mopeds),
            (LicenceCategory.a1, LicenceCategoryGroup.motorcycles),
            (LicenceCategory.a2, LicenceCategoryGroup.motorcycles),
            (LicenceCategory.a, LicenceCategoryGroup.motorcycles),
            (LicenceCategory.b1, LicenceCategoryGroup.lightVehicles),
            (LicenceCategory.b, LicenceCategoryGroup.cars),
            (LicenceCategory.be, LicenceCategoryGroup.cars),
            (LicenceCategory.c1, LicenceCategoryGroup.mediumSizedVehicles),
            (LicenceCategory.c1e, LicenceCategoryGroup.mediumSizedVehicles),
            (LicenceCategory.c, LicenceCategoryGroup.largeVehicles),
            (LicenceCategory.ce, LicenceCategoryGroup.largeVehicles),
            (LicenceCategory.d1, LicenceCategoryGroup.minibuses),
            (LicenceCategory.d1e, LicenceCategoryGroup.minibuses),
            (LicenceCategory.d, LicenceCategoryGroup.buses),
            (LicenceCategory.de, LicenceCategoryGroup.buses),
            (LicenceCategory.f, LicenceCategoryGroup.otherVehicles),
            (LicenceCategory.g, LicenceCategoryGroup.otherVehicles),
            (LicenceCategory.h, LicenceCategoryGroup.otherVehicles),
            (LicenceCategory.k, LicenceCategoryGroup.otherVehicles),
            (LicenceCategory.l, LicenceCategoryGroup.otherVehicles),
            (LicenceCategory.m, LicenceCategoryGroup.otherVehicles),
            (LicenceCategory.n, LicenceCategoryGroup.otherVehicles)
        ]
    )
    func group_returnsExpectedGroup(
        category: LicenceCategory,
        expectedGroup: LicenceCategoryGroup
    ) {
        #expect(category.group == expectedGroup)
    }

    // MARK: - Display Name

    @Test(
        arguments: [
            (LicenceCategory.am, "AM"),
            (LicenceCategory.p, "P"),
            (LicenceCategory.q, "Q"),
            (LicenceCategory.a1, "A1"),
            (LicenceCategory.a2, "A2"),
            (LicenceCategory.a, "A"),
            (LicenceCategory.b1, "B1"),
            (LicenceCategory.b, "B"),
            (LicenceCategory.be, "BE"),
            (LicenceCategory.c1, "C1"),
            (LicenceCategory.c1e, "C1E"),
            (LicenceCategory.c, "C"),
            (LicenceCategory.ce, "CE"),
            (LicenceCategory.d1, "D1"),
            (LicenceCategory.d1e, "D1E"),
            (LicenceCategory.d, "D"),
            (LicenceCategory.de, "DE"),
            (LicenceCategory.f, "f"),
            (LicenceCategory.g, "G"),
            (LicenceCategory.h, "H"),
            (LicenceCategory.k, "k"),
            (LicenceCategory.l, "l"),
            (LicenceCategory.m, "M"),
            (LicenceCategory.n, "N")
        ]
    )
    func displayName_returnsExpectedName(
        category: LicenceCategory,
        expectedDisplayName: String
    ) {
        #expect(category.displayName == expectedDisplayName)
    }

    // MARK: - Image Resource

    @Test(
        arguments: [
            (LicenceCategory.am, ImageResource.drivingCategoryAM),
            (LicenceCategory.p, ImageResource.drivingCategoryP),
            (LicenceCategory.q, ImageResource.drivingCategoryQ),
            (LicenceCategory.a1, ImageResource.drivingCategoryA1),
            (LicenceCategory.a2, ImageResource.drivingCategoryA2),
            (LicenceCategory.a, ImageResource.drivingCategoryA),
            (LicenceCategory.b1, ImageResource.drivingCategoryB1),
            (LicenceCategory.b, ImageResource.drivingCategoryB),
            (LicenceCategory.be, ImageResource.drivingCategoryBE),
            (LicenceCategory.c1, ImageResource.drivingCategoryC1),
            (LicenceCategory.c1e, ImageResource.drivingCategoryC1E),
            (LicenceCategory.c, ImageResource.drivingCategoryC),
            (LicenceCategory.ce, ImageResource.drivingCategoryCE),
            (LicenceCategory.d1, ImageResource.drivingCategoryD1),
            (LicenceCategory.d1e, ImageResource.drivingCategoryD1E),
            (LicenceCategory.d, ImageResource.drivingCategoryD),
            (LicenceCategory.de, ImageResource.drivingCategoryDE)
        ]
    )
    func image_forCategoryWithAsset_returnsExpectedResource(
        category: LicenceCategory,
        expectedImage: ImageResource
    ) {
        #expect(category.image == expectedImage)
    }

    @Test(
        arguments: [
            LicenceCategory.f,
            LicenceCategory.g,
            LicenceCategory.h,
            LicenceCategory.k,
            LicenceCategory.l,
            LicenceCategory.m,
            LicenceCategory.n
        ]
    )
    func image_forCategoryWithoutAsset_returnsNil(category: LicenceCategory) {
        #expect(category.image == nil)
    }
}
