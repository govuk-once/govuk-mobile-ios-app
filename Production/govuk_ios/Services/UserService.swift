protocol UserServiceInterface {
    func fetchUserState(completion: @escaping FetchUserStateCompletion)
    func setNotificationsConsent(_ consentStatus: ConsentStatus)
    func linkAccount(withType accountType: ServiceAccountType,
                     linkId: String,
                     completion: @escaping LinkAccountCompletion)
    func unlinkAccount(withType accountType: ServiceAccountType,
                       completion: @escaping UnlinkAccountCompletion)
    @discardableResult
    func fetchAccountLinkStatus(accountType: ServiceAccountType) async -> LinkStatusResult
    var pushId: String? { get }
    var notificationsConsentStatus: ConsentStatus? { get }
    var isEnabled: Bool { get }
    var isDvlaAccountLinked: Bool { get }
}

 class UserService: UserServiceInterface {
     private let appConfigService: AppConfigServiceInterface
     private let userServiceClient: UserServiceClientInterface
     private var userState: UserState?

     var isEnabled: Bool {
        #if STAGING
         appConfigService.isFeatureEnabled(key: .profile)
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

     /// Temporarily disable sending of consent
     /// https://govukverify.atlassian.net/browse/GOVUKAPP-3485
     func setNotificationsConsent(_ consentStatus: ConsentStatus) {
         return
         /*
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
        */
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
        accountType: ServiceAccountType
     ) async -> LinkStatusResult {
         let result = await userServiceClient.fetchAccountLinkStatus(
            serviceName: accountType.rawValue
         )
         if case .success(let status) = result {
             isDvlaAccountLinked = status.linked
         }
         return result
     }
 }
