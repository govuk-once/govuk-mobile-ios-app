import AuthenticationServices
@testable import govuk_ios

class MockASWebAuthenticationSession: NSObject, ASWebAuthenticationSessionInterface {

    static var lastInstance: MockASWebAuthenticationSession?

    override init() {
        prefersEphemeralWebBrowserSession = true
    }

    var _receivedUrl: URL?
    var _receivedCallbackURLScheme: String?
    var _receivedCompletionHandler: (ASWebAuthenticationSession.CompletionHandler)?
    required init(url: URL, callbackURLScheme: String?, completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler) {
        _receivedUrl = url
        _receivedCallbackURLScheme = callbackURLScheme
        _receivedCompletionHandler = completionHandler

        prefersEphemeralWebBrowserSession = true

        super.init()
        MockASWebAuthenticationSession.lastInstance = self
    }

    var prefersEphemeralWebBrowserSession: Bool

    var presentationContextProvider: (any ASWebAuthenticationPresentationContextProviding)?

    static var _stubbedCallbackUrl: URL?
    static var _stubbedError: Error?
    func start() -> Bool {
        _receivedCompletionHandler?(
            MockASWebAuthenticationSession._stubbedCallbackUrl,
            MockASWebAuthenticationSession._stubbedError
        )
        return true
    }


}
