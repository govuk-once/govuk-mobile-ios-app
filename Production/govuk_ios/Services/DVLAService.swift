import Foundation

protocol DVLAServiceInterface {
    func linkAccount(linkId: String, completion: @escaping LinkAccountCompletion)
}

 class DVLAService: DVLAServiceInterface {
     private let dvlaServiceClient: DVLAServiceClientInterface

     init(dvlaServiceClient: DVLAServiceClientInterface) {
         self.dvlaServiceClient = dvlaServiceClient
     }

     func linkAccount(linkId: String, completion: @escaping LinkAccountCompletion) {
         dvlaServiceClient.linkAccount(linkId: linkId, completion: completion)
     }
 }
