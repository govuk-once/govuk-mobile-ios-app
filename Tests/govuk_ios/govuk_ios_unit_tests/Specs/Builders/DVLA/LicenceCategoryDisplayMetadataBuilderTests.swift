import Foundation
import Testing

@testable import govuk_ios

@Suite
struct LicenceCategoryDisplayMetadataBuilderTests {
    @Test
    func buildMetadata_forKnownCategory_returnsExpectedResult() {
        let sut = LicenceCategoryDisplayMetadataBuilder()
        let result = sut.buildMetadata(for: "B")
        #expect(result.group == .cars)
        #expect(result.image == .drivingCategoryB)
        #expect(result.displayName  == "B")
    }

    @Test
    func buildMetadata_categoryCodeLookupIsCaseInsensitive() {
        let sut = LicenceCategoryDisplayMetadataBuilder()
        let result = sut.buildMetadata(for: "a")
        #expect(result.group == .motorcycles)
        #expect(result.image == .drivingCategoryA)
        #expect(result.displayName == "A")
    }

    @Test(
        arguments: [
            ("F", "f"),
            ("K", "k"),
            ("L", "l"),
            ("N", "n")
        ]
    )
    func buildMetadata_forSpecialLowercaseCategories_returnsLowercaseDisplayName(
        categoryCode: String,
        expectedDisplayName: String
    ) {
        let sut = LicenceCategoryDisplayMetadataBuilder()
        let result = sut.buildMetadata(for: categoryCode)
        #expect(result.displayName == expectedDisplayName)
    }

    @Test
    func buildMetadata_forUnknownCategory_returnsFallbackMetadata() {
        let sut = LicenceCategoryDisplayMetadataBuilder()
        let result = sut.buildMetadata(for: "XXZ")
        #expect(result.group == .otherVehicles)
        #expect(result.image == nil)
        #expect(result.displayName == "XXZ")
    }

    @Test
    func categoryRegistry_containsAllExpectedCategories() {
        #expect(LicenceCategoryDisplayMetadataBuilder.categoryRegistry.count == 24)
    }
}
