protocol UserServiceInterface {
    func fetchUserState(completion: @escaping FetchUserStateCompletion)
    func setNotificationsConsent(_ consentStatus: ConsentStatus)
    func linkAccount(withType accountType: ServiceAccountType,
                     token: String,
                     completion: @escaping LinkAccountCompletion)
    func unlinkAccount(withType accountType: ServiceAccountType,
                       completion: @escaping UnlinkAccountCompletion)
    func fetchLinkedAccounts() async -> Result<[ServiceAccountType], UserStateError>
    var pushId: String? { get }
    var notificationsConsentStatus: ConsentStatus? { get }
    var isEnabled: Bool { get }
    var linkedAccounts: [ServiceAccountType]? { get }
}

 class UserService: UserServiceInterface {
     private let appConfigService: AppConfigServiceInterface
     private let userServiceClient: UserServiceClientInterface
     private var userState: UserState?

     var isEnabled: Bool {
         appConfigService.isFeatureEnabled(key: .profile)
     }

     var pushId: String? {
         userState?.notifications.pushId
     }
     var notificationsConsentStatus: ConsentStatus? {
         userState?.notifications.consentStatus
     }

     // lets move this out of here in the future
     var linkedAccounts: [ServiceAccountType]?

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
                      token: String,
                      completion: @escaping LinkAccountCompletion) {
         userServiceClient.linkAccount(
            serviceName: accountType.rawValue,
            token: token,
            completion: { [weak self] result in
                if case .success = result {
                    self?.addLinkedAccount(accountType)
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
                    self?.removeLinkedAccount(accountType)
                }
                completion(result)
            }
         )
     }

     func fetchLinkedAccounts() async -> Result<[ServiceAccountType], UserStateError> {
         let result = await userServiceClient.fetchLinkedAccounts()
         switch result {
         case .success(let response):
             self.linkedAccounts = response.services
             return .success(response.services)
         case .failure(let error):
             return .failure(error)
         }
     }

     private func addLinkedAccount(_ accountType: ServiceAccountType) {
         if linkedAccounts == nil {
             linkedAccounts = [accountType]
         } else {
             linkedAccounts?.append(accountType)
         }
     }

     private func removeLinkedAccount(_ accountType: ServiceAccountType) {
         if let indexOfAccount = linkedAccounts?.firstIndex(of: accountType) {
             linkedAccounts?.remove(at: indexOfAccount)
         }
     }
 }
