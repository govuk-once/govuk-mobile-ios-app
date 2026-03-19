import Foundation

struct LocalWasteBin: Codable, Hashable {
    let date: Date
    let name: String
    let color: LocalWasteBinColor?
    let content: String?

    private enum CodingKeys: String, CodingKey {
        case date = "date"
        case name = "binName"
        case color = "binColour"
        case content = "binContent"
    }
}

enum LocalWasteBinColor: String, Codable, Hashable {
    case black
    case green
    case red
    case blue
    case brown
    case yellow
    case silver
    case purple
}

struct LocalWasteScheduleError: Codable, Hashable {
    let message: LocalWasteScheduleErrorMessage
}

enum LocalWasteScheduleErrorMessage: String, Codable, Hashable {
    case councilNotSupported
    case invalidUPRN
    case unknownError
}
