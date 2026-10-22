// MARK: - Composite State Model
enum StateLabelContent: Equatable {
    case normal(String)
    case error(String)

    var isNormal: Bool {
        if case .normal = self { return true }
        return false
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }

    var text: String {
        switch self {
        case .normal(let text), .error(let text): return text
        }
    }
}

extension StateLabelContent: CustomStringConvertible {
    var description: String {
        switch self {
        case .normal(let string):
            "normal: \(string)"
        case .error(let string):
            "error: \(string)"
        }
    }
}
