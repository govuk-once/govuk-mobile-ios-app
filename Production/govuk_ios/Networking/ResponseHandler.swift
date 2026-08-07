import Foundation

protocol ResponseHandler {
    func handleResponse(_ response: URLResponse?,
                        data: Data?,
                        error: Error?) -> Error?
    func parseError(from data: Data) -> Error?
    func handleStatusCode(_ statusCode: Int) -> Error
}

extension ResponseHandler {
    func handleResponse(_ response: URLResponse?,
                        data: Data?,
                        error: Error?) -> Error? {
        guard error == nil else {
            return error
        }
        guard let httpURLResponse = response as? HTTPURLResponse else {
            return nil
        }

        let statusCode = httpURLResponse.statusCode
        if (200..<300).contains(statusCode) {
            return nil
        }

        if let data = data,
           let parsedError = parseError(from: data) {
            return parsedError
        }
        return handleStatusCode(statusCode)
    }

    func parseError(from _: Data) -> Error? {
        nil
    }
}
