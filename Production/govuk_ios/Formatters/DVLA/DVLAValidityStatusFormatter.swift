import Foundation

struct DVLAValidityStatusFormatter {
    private let dateFormatter: DateFormatter = .dvlaAccount

    func formatStatus(from expiryDate: Date?) -> String {
        if let expiryDate = expiryDate {
            let expiryDateString = dateFormatter.string(from: expiryDate)
            let format = String.dvla.localized("validUntil")
            return String.localizedStringWithFormat(format, expiryDateString)
        } else {
            return String.dvla.localized("unknown")
        }
    }
}
