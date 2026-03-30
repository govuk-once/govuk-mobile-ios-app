protocol UserServiceInterface {
    func fetchUserState(completion: @escaping FetchUserStateCompletion)
    func setNotificationsConsent(_ consentStatus: ConsentStatus)
    func linkAccount(withType accountType: ServiceAccountType,
                     linkId: String,
                     completion: @escaping LinkAccountCompletion)
    func unlinkAccount(withType accountType: ServiceAccountType,
                       completion: @escaping UnlinkAccountCompletion)
    func fetchAccountLinkStatus(accountType: ServiceAccountType,
                                completion: @escaping LinkStatusCompletion)
    var notificationId: String? { get }
    var notificationsConsentStatus: ConsentStatus? { get }
    var isEnabled: Bool { get }
    var isDvlaAccountLinked: Bool { get }
}

 class UserService: UserServiceInterface {
     private let appConfigService: AppConfigServiceInterface
     private let userServiceClient: UserServiceClientInterface
     private var userState: UserState?

     var isEnabled: Bool {
         appConfigService.isFeatureEnabled(key: .flex)
     }

     var notificationId: String? {
         userState?.notifications.notificationId
     }
     var notificationsConsentStatus: ConsentStatus? {
         userState?.notifications.consentStatus
     }

     // temporary
     var isDvlaAccountLinked = false

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

     func linkAccount(withType accountType: ServiceAccountType,
                      linkId: String,
                      completion: @escaping LinkAccountCompletion) {
         userServiceClient.linkAccount(
            serviceName: accountType.rawValue,
            linkId: linkId,
            completion: { [weak self] result in
                if case .success = result {
                    self?.isDvlaAccountLinked = true
                }
                completion(result)
            }
         )
     }

     func unlinkAccount(withType accountType: ServiceAccountType,
                        completion: @escaping UnlinkAccountCompletion) {
         userServiceClient.unlinkAccount(
            serviceName: accountType.rawValue,
            completion: { [weak self] result in
                if case .success = result {
                    self?.isDvlaAccountLinked = false
                }
                completion(result)
            }
         )
     }

     func fetchAccountLinkStatus(
        accountType: ServiceAccountType,
        completion: @escaping LinkStatusCompletion
     ) {
         userServiceClient.fetchAccountLinkStatus(
            serviceName: accountType.rawValue,
            completion: { [weak self] result in
                if case .success(let status) = result {
                    self?.isDvlaAccountLinked = status.linked
                }
                completion(result)
            }
         )
     }
 }
