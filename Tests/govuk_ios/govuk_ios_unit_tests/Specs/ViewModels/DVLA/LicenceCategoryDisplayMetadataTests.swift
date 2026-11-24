import Foundation
import Testing

@testable import govuk_ios

@Suite
struct LicenceCategoryDisplayMetadataTests {

    // MARK: - Known Categories

    @Test
    func init_withKnownCategoryCode_populatesCorrectMetadata() {
        let metadata = LicenceCategoryDisplayMetadata(categoryCode: "B")

        #expect(metadata.displayName == "B")
        #expect(metadata.group == .cars)
        #expect(metadata.image == .drivingCategoryB)
    }

    @Test
    func init_withKnownCategoryInstance_populatesCorrectMetadata() {
        let metadata = LicenceCategoryDisplayMetadata(category: .be)

        #expect(metadata.displayName == "BE")
        #expect(metadata.group == .cars)
        #expect(metadata.image == .drivingCategoryBE)
    }

    // MARK: - Special Lowercase Categories

    @Test(
        arguments: [
            ("f", "f"),
            ("k", "k"),
            ("l", "l")
        ]
    )
    func init_withSpecialLowercaseCategoryCode_retainsLowercaseCasing(
        inputCode: String,
        expectedDisplayCode: String
    ) {
        let metadata = LicenceCategoryDisplayMetadata(categoryCode: inputCode)

        #expect(metadata.displayName == expectedDisplayCode)
        #expect(metadata.group == .otherVehicles)
        #expect(metadata.image == nil)
    }

    // MARK: - Fallback / Unrecognized Handling

    @Test
    func init_withUnrecognizedCategoryCode_fallsBackGracefully() {
        let unknownCode = "XYZ"
        let metadata = LicenceCategoryDisplayMetadata(categoryCode: unknownCode)

        #expect(metadata.displayName == unknownCode)
        #expect(metadata.group == .otherVehicles)
        #expect(metadata.image == nil)
    }
}
