import Foundation
import Testing

@testable import govuk_ios

@Suite
struct RegistrationNumberFormatterTests {

    @Test
    func sanitize_emptyInput_returnsEmptyString() {
        let result = RegistrationNumberFormatter.sanitize("")
        #expect(result == "")
    }

    @Test
    func sanitize_lowercasedInput_convertsToUppercase() {
        let result = RegistrationNumberFormatter.sanitize("ab12cde")
        #expect(result == "AB12CDE")
    }

    @Test
    func sanitize_containsPeriod_replacesWithSpace() {
        let result = RegistrationNumberFormatter.sanitize("AB12.CDE")
        #expect(result == "AB12 CDE")
    }

    @Test
    func sanitize_leadingWhitespaceOrPeriod_omitsLeadingSpace() {
        let leadingSpaceResult = RegistrationNumberFormatter.sanitize(" AB12 CDE")
        let leadingPeriodResult = RegistrationNumberFormatter.sanitize(".AB12 CDE")

        #expect(leadingSpaceResult == "AB12 CDE")
        #expect(leadingPeriodResult == "AB12 CDE")
    }

    @Test
    func sanitize_consecutiveWhitespacesOrPeriods_collapsesToSingleSpace() {
        let result = RegistrationNumberFormatter.sanitize("AB12...  CDE")
        #expect(result == "AB12 CDE")
    }

    @Test
    func sanitize_disallowedCharacters_filtersOutSymbolsAndPunctuation() {
        let result = RegistrationNumberFormatter.sanitize("AB-12! @#CDE$")
        #expect(result == "AB12 CDE")
    }

    @Test
    func sanitize_exceedsDefaultMaxAlphanumerics_truncatesAtSevenCharacters() {
        let result = RegistrationNumberFormatter.sanitize("AB12CDEFGH")
        #expect(result == "AB12CDE")
    }

    @Test
    func sanitize_customMaxAlphanumerics_truncatesAtSpecifiedLimit() {
        let result = RegistrationNumberFormatter.sanitize("AB12 CDE", maxAlphanumerics: 4)
        #expect(result == "AB12")
    }

    @Test
    func sanitize_whitespaceAfterMaxAlphanumericsReached_doesNotAppendTrailingSpace() {
        let result = RegistrationNumberFormatter.sanitize("AB12CDE ")
        #expect(result == "AB12CDE")
    }

    @Test(arguments: zip(
        [
            "ld02 pkh",
            "CU04HYW",
            "A1.B2",
            "  1   A   "
        ],
        [
            "LD02 PKH",
            "CU04HYW",
            "A1 B2",
            "1 A "
        ]
    ))
    func sanitize_commonRegistrationInputs_returnsExpectedFormattedOutput(
        input: String,
        expected: String
    ) {
        let result = RegistrationNumberFormatter.sanitize(input)
        #expect(result == expected)
    }
}
