protocol UserServiceInterface {
    func fetchUserState(completion: @escaping FetchUserStateCompletion)
    func setNotificationsConsent(_ consentStatus: ConsentStatus)
    var notificationsConsentStatus: ConsentStatus? { get }
    var isEnabled: Bool { get }
}

 class UserService: UserServiceInterface {
     private let appConfigService: AppConfigServiceInterface
     private let userServiceClient: UserServiceClientInterface
     private var userState: UserState?

     var isEnabled: Bool {
        #if STAGING
         appConfigService.isFeatureEnabled(key: .flex)
        #else
         false
        #endif
     }

     var notificationsConsentStatus: ConsentStatus? {
         userState?.preferences.notifications.consentStatus
     }

     init(appConfigService: AppConfigServiceInterface,
          userServiceClient: UserServiceClientInterface) {
         self.appConfigService = appConfigService
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
         guard isEnabled else { return }
         userServiceClient.setNotificationsConsent(consentStatus) { result in
             switch result {
             case .success:
                 print("userServiceClient.setNotificationsConsent successful")
             case .failure(let error):
                 print(error.localizedDescription)
             }
         }
     }
 }
