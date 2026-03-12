protocol UserServiceInterface {
    func fetchUserState(completion: @escaping FetchUserStateCompletion)
    func setNotificationsConsent(_ consentStatus: ConsentStatus)
    func linkAccount(withType accountType: ServiceAccountType,
                     linkId: String,
                     completion: @escaping LinkAccountCompletion)
    var notificationId: String? { get }
    var notificationsConsentStatus: ConsentStatus? { get }
    var isEnabled: Bool { get }
}

 class UserService: UserServiceInterface {
     private let appConfigService: AppConfigServiceInterface
     private let userServiceClient: UserServiceClientInterface
     private var userState: UserState?

     var isEnabled: Bool {
         appConfigService.isFeatureEnabled(key: .flex)
     }

     var notificationId: String? {
         userState?.notificationId
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
             case .success(let response):
                 let returnedConsentStatus = response.preferences.notifications.consentStatus
                 print("\(#function) successful, result: \(returnedConsentStatus.rawValue)")
             case .failure(let error):
                 print(error.localizedDescription)
             }
         }
     }

     func linkAccount(withType accountType: ServiceAccountType,
                      linkId: String,
                      completion: @escaping LinkAccountCompletion) {
         userServiceClient.linkAccount(
            serviceName: accountType.rawValue,
            linkId: linkId,
            completion: completion
         )
     }
 }
