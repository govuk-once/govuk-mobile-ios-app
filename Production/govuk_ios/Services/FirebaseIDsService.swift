import Foundation

protocol FirebaseIDsServiceInterface {
    var appInstanceID: String { get }
    var sessionID: String { get }
    func updateSessionID()
}

class FirebaseIDsService: FirebaseIDsServiceInterface {
    private let firebaseAnalytics: FirebaseAnalyticsInterface.Type

    private(set) var appInstanceID: String
    private(set) var sessionID: String = ""

    init(firebaseAnalytics: FirebaseAnalyticsInterface.Type) {
        self.firebaseAnalytics = firebaseAnalytics
        self.appInstanceID = firebaseAnalytics.appInstanceID() ?? ""
        updateSessionID()
    }

    func updateSessionID() {
        Task {
            let fetchedSessionID = try? await firebaseAnalytics.sessionID()
            if let fetchedSessionID = fetchedSessionID {
                sessionID = "\(fetchedSessionID)"
            }
        }
    }
}
