import Foundation

extension HTTPURLResponse {
    var isSuccessful: Bool {
        statusCode.isHTTPSuccess
    }

    var isError: Bool {
        statusCode.isHTTPError
    }
}

extension Int {
    var isHTTPSuccess: Bool {
        (200..<300).contains(self)
    }

    var isHTTPError: Bool {
        (400...599).contains(self)
    }
}
