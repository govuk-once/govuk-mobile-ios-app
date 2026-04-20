protocol UserServiceInterface {
    func fetchUserState(completion: @escaping FetchUserStateCompletion)
    func setNotificationsConsent(_ consentStatus: ConsentStatus)
    var pushId: String? { get }
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

     var pushId: String? {
         userState?.notifications.pushId
     }
     var notificationsConsentStatus: ConsentStatus? {
         userState?.notifications.consentStatus
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
             case .success(let response):
                 let returnedConsentStatus = response.consentStatus
                 print("\(#function) successful, result: \(returnedConsentStatus.rawValue)")
             case .failure(let error):
                 print(error.localizedDescription)
             }
         }
     }
 }
