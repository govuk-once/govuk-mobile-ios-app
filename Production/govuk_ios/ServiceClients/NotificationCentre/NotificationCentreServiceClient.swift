//

import Foundation

typealias NotificationResult = Result<[Notification], NotificationCentreError>
typealias SingleNotificationResult = Result<Notification?, NotificationCentreError>

protocol NotificationCentreServiceClientInterface {
    func fetchNotifications(callback: @escaping (NotificationResult) -> Void)
    func fetchNotification(
        with id: String,
        callback: @escaping (SingleNotificationResult) -> Void)

    func updateNotification(
        status: GOVRequest.UpdateBody.Status,
        for id: String,
        with callback: @escaping () -> Void)

    func deleteNotification(
        with id: String,
        callback: @escaping () -> Void)
}

struct NotificationCentreServiceClient: NotificationCentreServiceClientInterface {
    private let apiServiceClient: APIServiceClientInterface


    init(apiServiceClient: APIServiceClientInterface) {
        self.apiServiceClient = apiServiceClient
    }

    func fetchNotifications(callback: @escaping (NotificationResult) -> Void) {
        let request = GOVRequest.notifications
        apiServiceClient.send(request: request) { result in
            callback(mapResult(result))
        }
    }

    func fetchNotification(with id: String,
                           callback: @escaping (SingleNotificationResult) -> Void) {
        let request = GOVRequest.singleNotification(with: id)
        apiServiceClient.send(request: request) { result in
            callback(mapResult(result))
        }
    }

    func updateNotification(
        status: GOVRequest.UpdateBody.Status,
        for id: String,
        with callback: @escaping () -> Void) {
            let request = GOVRequest.update(status: status, with: id)
            apiServiceClient.send(request: request) { _ in
                callback()
            }
        }

    func deleteNotification(with id: String,
                            callback: @escaping () -> Void) {
        let request = GOVRequest.deleteNotification(with: id)
        apiServiceClient.send(request: request) { _ in
            callback()
        }
    }

    private func mapResult<T: Decodable>(
        _ result: NetworkResult<Data>
    ) -> Result<T, NotificationCentreError> {
        return result.mapError { error in
            return (error as? NotificationCentreError) ?? NotificationCentreError.apiUnavailable
        }.flatMap {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(T.self, from: $0)
                return .success(response)
            } catch {
                return .failure(NotificationCentreError.decodingError)
            }
        }
    }
}
