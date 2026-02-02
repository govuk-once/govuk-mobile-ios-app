protocol UserServiceInterface {
     func fetchUserState(completion: @escaping FetchUserStateCompletion)
 }

 class UserService: UserServiceInterface {
     private let userServiceClient: UserServiceClientInterface

     init(userServiceClient: UserServiceClientInterface) {
         self.userServiceClient = userServiceClient
     }

     func fetchUserState(completion: @escaping FetchUserStateCompletion) {
         userServiceClient.fetchUserState(completion: completion)
     }
 }
