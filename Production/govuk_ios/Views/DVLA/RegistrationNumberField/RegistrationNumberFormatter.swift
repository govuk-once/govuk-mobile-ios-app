import Foundation

/// Pure formatting logic for UK registration number plates: uppercase A-Z/0-9, single spaces, period interception.
enum RegistrationNumberFormatter {
    private static let allowedCharacters = CharacterSet(
        charactersIn:
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    )

    static func sanitize(_ value: String, maxAlphanumerics: Int = 7) -> String {
        let sanitizedInput = value.replacingOccurrences(of: ".", with: " ")
        var result = ""
        var alphanumericCount = 0
        var lastCharWasSpace = false

        for scalar in sanitizedInput.uppercased().unicodeScalars {
            if CharacterSet.whitespaces.contains(scalar) {
                if !result.isEmpty && !lastCharWasSpace && alphanumericCount < maxAlphanumerics {
                    result.append(" ")
                    lastCharWasSpace = true
                }
            } else if allowedCharacters.contains(scalar) {
                if alphanumericCount < maxAlphanumerics {
                    result.append(Character(scalar))
                    alphanumericCount += 1
                    lastCharWasSpace = false
                } else {
                    break
                }
            }
        }

        return result
    }
}
