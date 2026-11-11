import Foundation
import Testing

@testable import govuk_ios

@Suite
struct LicenceCategoryDisplayMetadataBuilderTests {
    @Test
    func buildMetadata_forKnownCategory_returnsExpectedResult() {
        let result = LicenceCategoryDisplayMetadataBuilder.metadata(for: "B")
        #expect(result.group == .cars)
        #expect(result.image == .drivingCategoryB)
        #expect(result.displayName  == "B")
    }

    @Test
    func buildMetadata_categoryCodeLookupIsCaseInsensitive() {
        let result = LicenceCategoryDisplayMetadataBuilder.metadata(for: "a")
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
        let result = LicenceCategoryDisplayMetadataBuilder.metadata(for: categoryCode)
        #expect(result.displayName == expectedDisplayName)
    }

    @Test
    func buildMetadata_forUnknownCategory_returnsFallbackMetadata() {
        let result = LicenceCategoryDisplayMetadataBuilder.metadata(for: "XXZ")
        #expect(result.group == .otherVehicles)
        #expect(result.image == nil)
        #expect(result.displayName == "XXZ")
    }

    @Test
    func categoryRegistry_containsAllExpectedCategories() {
        #expect(LicenceCategoryDisplayMetadataBuilder.categoryRegistry.count == 24)
    }
}
