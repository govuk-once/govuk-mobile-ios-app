import Foundation
import Security

final class ZscalerTrustDelegate: NSObject, URLSessionDelegate {
    private let zscalerCertificate: SecCertificate?

    override init() {
        if let certURL = Bundle.main.url(forResource: "zscaler_root_ca", withExtension: "der"),
           let certData = try? Data(contentsOf: certURL),
           let certificate = SecCertificateCreateWithData(nil, certData as CFData) {
            zscalerCertificate = certificate
        } else {
            zscalerCertificate = nil
        }
        super.init()
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let method = challenge.protectionSpace.authenticationMethod
        guard method == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let zscalerCertificate = zscalerCertificate else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        SecTrustSetAnchorCertificates(serverTrust, [zscalerCertificate] as CFArray)
        SecTrustSetAnchorCertificatesOnly(serverTrust, false)

        var error: CFError?
        if SecTrustEvaluateWithError(serverTrust, &error) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
