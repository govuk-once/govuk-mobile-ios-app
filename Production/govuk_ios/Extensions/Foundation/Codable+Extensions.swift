import Foundation

extension Decodable {
    private func endBraceIndex(for jsonString: String,
                               in range: Range<String.Index>) -> String.Index {
        let start = range.upperBound
        var braceCount = 0
        var endIndex = start
        for index in jsonString[start...].indices {
            let char = jsonString[index]
            if char == "{" {
                braceCount += 1
            } else if char == "}" {
                braceCount -= 1
                if braceCount == 0 {
                    endIndex = jsonString.index(after: index)
                    break
                }
            }
        }
        return endIndex
    }

    private func data(from jsonString: String, removePrettyPrint: Bool) -> Data? {
        var stringCopy = jsonString
        if removePrettyPrint {
            stringCopy = jsonString
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: " ", with: "")
        }
        return stringCopy.data(using: .utf8)
    }
}
