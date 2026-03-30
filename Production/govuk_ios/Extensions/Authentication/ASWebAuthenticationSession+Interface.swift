import AuthenticationServices

protocol ASWebAuthenticationSessionInterface: NSObject {
    init(url: URL,
         callbackURLScheme: String?,
         completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler
    )
    var prefersEphemeralWebBrowserSession: Bool { get set }
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding? { get set }
    @discardableResult
    func start() -> Bool
}

extension ASWebAuthenticationSession: ASWebAuthenticationSessionInterface {}
