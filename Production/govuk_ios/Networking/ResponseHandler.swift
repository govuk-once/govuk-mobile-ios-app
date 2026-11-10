import Foundation

protocol ResponseHandler {
    func handleResponse(_ response: URLResponse?,
                        data: Data?,
                        error: Error?) -> Error?
    func parseError(from data: Data, statusCode: Int) -> Error?
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

        if httpURLResponse.isSuccessful {
            return nil
        }

        if let data = data,
           let parsedError = parseError(from: data, statusCode: httpURLResponse.statusCode) {
            return parsedError
        }
        return handleStatusCode(httpURLResponse.statusCode)
    }

    func parseError(from _: Data, statusCode _: Int) -> Error? {
        nil
    }
}
