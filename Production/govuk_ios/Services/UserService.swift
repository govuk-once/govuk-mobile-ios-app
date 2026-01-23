protocol UserServiceInterface {
     func fetchUserInfo(completion: @escaping FetchUserInfoCompletion)
 }

 struct UserService: UserServiceInterface {
     private let userServiceClient: UserServiceClientInterface

     init(userServiceClient: UserServiceClientInterface) {
         self.userServiceClient = userServiceClient
     }

     func fetchUserInfo(completion: @escaping FetchUserInfoCompletion) {
         userServiceClient.fetchUserInfo(completion: completion)
     }
 }
