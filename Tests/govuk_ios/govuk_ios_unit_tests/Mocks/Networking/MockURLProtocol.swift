import Foundation

class MockURLProtocol: URLProtocol {

    typealias Handler = (URLRequest) -> (HTTPURLResponse, Data?, Error?)

    static let sessionIdHeader = "X-Mock-Session-Id"

    private static let unspecifiedSessionId = "00000000-0000-0000-0000-000000000000"

    private static let queue = DispatchQueue(label: "com.tests.mockurlprotocol.requesthandlers")

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    private static var handlersBySessionID: [String: [String: Handler]] = [:]

    static func registerHandler(
        sessionId: String = unspecifiedSessionId,
        forUrl url: String,
        handler: @escaping Handler
    ) {
        queue.sync {
            var handlers = handlersBySessionID[sessionId] ?? [:]
            handlers[url] = handler
            handlersBySessionID[sessionId] = handlers
        }
    }

    override func startLoading() {
        guard let requestUrl = request.url,
              var components = URLComponents(url: requestUrl, resolvingAgainstBaseURL: true)
        else { fatalError("URL is unavailable.") }

        components.queryItems = nil

        guard let url = components.url?.absoluteString else {
            fatalError("URL string is missing")
        }

        let sessionId = request.value(forHTTPHeaderField: Self.sessionIdHeader)
            ?? Self.unspecifiedSessionId

        let handler: Handler? = Self.queue.sync {
            Self.handlersBySessionID[sessionId]?[url]
        }

        guard let handler else {
            if sessionId == Self.unspecifiedSessionId {
                fatalError("No handler registered for url=\(url)")
            } else {
                fatalError("No handler registered for sessionId=\(sessionId), url=\(url)")
            }
        }

        let (response, data, error) = handler(request)

        if let error = error {
            client?.urlProtocol(
                self,
                didFailWithError: error
            )
        } else {
            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
        }

        if let data = data {
            client?.urlProtocol(
                self,
                didLoad: data
            )
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        
    }

}

extension URLSession {
    static var mock: URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return .init(configuration: config)
    }

    static func mock(sessionId: String) -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        config.httpAdditionalHeaders = [
            MockURLProtocol.sessionIdHeader: sessionId
        ]
        return URLSession(configuration: config)
    }
}
