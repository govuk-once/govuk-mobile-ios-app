import Foundation

struct LocalWasteAddress: Codable, Hashable {
    let addressFull: String
    let uprn: String
    let localCustodianCode: String
}

struct LocalWasteAddressError: Codable, Hashable {
    let message: LocalWasteAddressesErrorMessage
}

enum LocalWasteAddressesErrorMessage: String, Codable, Hashable {
    case councilNotSupported
    case postcodeNotFound
    case invalidPostcode
    case unknownError
}
