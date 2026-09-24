import Foundation
import Firebase
import FirebaseCore
import FirebaseAppCheck

class GovUKProviderFactory: NSObject,
                            AppCheckProviderFactory {
        func createProvider(with app: FirebaseApp) -> (any AppCheckProvider)? {
            return createProviderInternal(with: app)
        }
        func createProviderInternal(with app: any FirebaseAppInterface) -> (any AppCheckProvider)? {
            #if STAGING
            return EmptyTokenProvider()
            #else
            guard let concreteApp = app as? FirebaseApp else { return nil }
            return AppAttestProvider(app: concreteApp)
            #endif
        }
}

class EmptyTokenProvider: NSObject,
                          AppCheckProvider {
    func getToken(completion: @escaping (AppCheckToken?, Error?) -> Void) {
        completion(.init(token: "", expirationDate: .distantFuture), nil)
    }
}
