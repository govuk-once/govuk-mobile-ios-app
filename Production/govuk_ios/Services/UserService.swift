protocol UserServiceInterface {
    func fetchUserState(completion: @escaping FetchUserStateCompletion)
    func setNotificationsConsent(accepted: Bool)
}

 class UserService: UserServiceInterface {
     private let userServiceClient: UserServiceClientInterface

     init(userServiceClient: UserServiceClientInterface) {
         self.userServiceClient = userServiceClient
     }

     func fetchUserState(completion: @escaping FetchUserStateCompletion) {
         userServiceClient.fetchUserState(completion: completion)
     }

     func setNotificationsConsent(accepted: Bool) {
         userServiceClient.setNotificationsConsent(accepted: accepted) { _ in }
     }
 }
