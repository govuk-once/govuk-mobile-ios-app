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

    // MARK: - Direct Initializer Tests

    @Test
    func init_withKnownCategoryCode_initializesCorrectMetadata() {
        let result = LicenceCategoryDisplayMetadata(categoryCode: "B")
        #expect(result.group == .cars)
        #expect(result.image == .drivingCategoryB)
        #expect(result.displayName == "B")
    }

    @Test
    func init_withUnknownCategoryCode_returnsFallbackMetadata() {
        let result = LicenceCategoryDisplayMetadata(categoryCode: "UNKNOWN")
        #expect(result.group == .otherVehicles)
        #expect(result.image == nil)
        #expect(result.displayName == "UNKNOWN")
    }

    // MARK: - Edge Cases & Preservation Tests

    @Test
    func init_preservesOriginalCasingInFallbackDisplayName() {
        let original = "customCode123"
        let result = LicenceCategoryDisplayMetadata(categoryCode: original)
        #expect(result.displayName == original)
        #expect(result.group == .otherVehicles)
        #expect(result.image == nil)
    }

    @Test(arguments: ["", " ", "  \t\n  "])
    func init_withEmptyOrWhitespaceCode_returnsFallbackMetadata(blankCode: String) {
        let result = LicenceCategoryDisplayMetadata(categoryCode: blankCode)
        #expect(result.group == .otherVehicles)
        #expect(result.image == nil)
        #expect(result.displayName == blankCode)
    }

    @Test
    func categoryRegistry_allSpecialLowercaseCategoriesHaveNilImage() {
        let specialCodes = ["F", "G", "H", "K", "L", "M", "N"]
        for code in specialCodes {
            let metadata = LicenceCategoryDisplayMetadataBuilder.categoryRegistry[code]
            #expect(metadata != nil)
            #expect(metadata?.group == .otherVehicles)
            #expect(metadata?.image == nil)
        }
    }
}
