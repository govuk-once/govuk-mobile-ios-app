protocol UserServiceInterface {
    func fetchUserState(completion: @escaping FetchUserStateCompletion)
    func setNotificationsConsent(_ consentStatus: ConsentStatus)
    var notificationsConsentStatus: ConsentStatus? { get }
}

 class UserService: UserServiceInterface {
     private let userServiceClient: UserServiceClientInterface
     private var userState: UserState?

     var notificationsConsentStatus: ConsentStatus? {
         userState?.preferences.notifications.consentStatus
     }

     init(userServiceClient: UserServiceClientInterface) {
         self.userServiceClient = userServiceClient
     }

     func fetchUserState(completion: @escaping FetchUserStateCompletion) {
         userServiceClient.fetchUserState { result in
             switch result {
             case .success(let userState):
                 self.userState = userState
                 completion(.success(userState))
             case .failure(let error):
                 completion(.failure(error))
             }
         }
     }

     func setNotificationsConsent(_ consentStatus: ConsentStatus) {
         userServiceClient.setNotificationsConsent(consentStatus) { _ in
             // not doing anything with the result, yet
         }
     }
 }
