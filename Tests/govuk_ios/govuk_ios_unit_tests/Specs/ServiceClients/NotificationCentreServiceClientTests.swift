//

import Foundation
import Testing
@testable import govuk_ios

@Suite
struct NotificationCentreServiceClientTests {

    var mockAPI: MockAPIServiceClient!
    var sut: NotificationCentreServiceClient!

    init() {
        mockAPI = MockAPIServiceClient()
        sut = NotificationCentreServiceClient(
            apiServiceClient: mockAPI
        )
    }

    // MARK: - Fetch notifications

    @Test
    func fetchNotifications_sendsExpectedRequest() {
        sut.fetchNotifications { _ in }
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/uns/v1/notifications")
        #expect(mockAPI._receivedSendRequest?.method == .get)
    }

    @Test
    func fetchNotifications_success_returnsExpectedResult() async {
        mockAPI._stubbedSendResponse = .success(NotificationCentreServiceClientTests.multipleNotificationsData)
        let result = await withCheckedContinuation { continuation in
            sut.fetchNotifications { result in
                continuation.resume(returning: result)
            }
        }
        let notifications = try? result.get()
        #expect(notifications != nil)
        #expect(notifications?.count == 2)
    }

    @Test
    func fetchNotifications_failure_returnsApiUnavailableError() async {
        mockAPI._stubbedSendResponse = .failure(NotificationCentreError.apiUnavailable)
        let result = await withCheckedContinuation { continuation in
            sut.fetchNotifications { result in
                continuation.resume(returning: result)
            }
        }
        let notifications = try? result.get()
        #expect(notifications == nil)
        #expect(result.getError() == .apiUnavailable)
    }

    @Test
    func fetchNotifications_invalidJson_returnsDecodingError() async {
        mockAPI._stubbedSendResponse = .success("bad json".data(using: .utf8)!)
        let result = await withCheckedContinuation { continuation in
            sut.fetchNotifications { result in
                continuation.resume(returning: result)
            }
        }
        let notifications = try? result.get()
        #expect(notifications == nil)
        #expect(result.getError() == .decodingError)
    }

    @Test
    func fetchNotifications_networkUnavailable_returnsNetworkUnavailableError() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: NSURLErrorNotConnectedToInternet)
        )
        let result = await withCheckedContinuation { continuation in
            sut.fetchNotifications { result in
                continuation.resume(returning: result)
            }
        }
        let notifications = try? result.get()
        #expect(notifications == nil)
        #expect(result.getError() == .networkUnavailable)
    }

    // MARK: - Fetch single notification

    @Test
    func fetchSingleNotification_sendsExpectedRequest() {
        sut.fetchNotification(with: "1") { _ in }
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/uns/v1/notifications/1")
        #expect(mockAPI._receivedSendRequest?.method == .get)
    }

    @Test
    func fetchSingleNotification_success_returnsExpectedResult() async {
        mockAPI._stubbedSendResponse = .success(NotificationCentreServiceClientTests.singleNotificationData)
        let result = await withCheckedContinuation { continuation in
            sut.fetchNotification(with: "1") { result in
                continuation.resume(returning: result)
            }
        }
        let notification = try? result.get()
        #expect(notification != nil)
    }

    @Test
    func fetchSingleNotification_failure_returnsApiUnavailableError() async {
        mockAPI._stubbedSendResponse = .failure(NotificationCentreError.apiUnavailable)
        let result = await withCheckedContinuation { continuation in
            sut.fetchNotification(with: "1") { result in
                continuation.resume(returning: result)
            }
        }
        let notification = try? result.get()
        #expect(notification == nil)
    }

    @Test
    func fetchSingleNotification_invalidJson_returnsDecodingError() async {
        mockAPI._stubbedSendResponse = .success("bad json".data(using: .utf8)!)
        let result = await withCheckedContinuation { continuation in
            sut.fetchNotification(with: "1") { result in
                continuation.resume(returning: result)
            }
        }
        let notification = try? result.get()
        #expect(notification == nil)
        #expect(result.getError() == .decodingError)
    }

    @Test
    func fetchSingleNotification_networkUnavailable_returnsNetworkUnavailableError() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: NSURLErrorNotConnectedToInternet)
        )
        let result = await withCheckedContinuation { continuation in
            sut.fetchNotification(with: "1") { result in
                continuation.resume(returning: result)
            }
        }
        let notification = try? result.get()
        #expect(notification == nil)
        #expect(result.getError() == .networkUnavailable)
    }
    // MARK: - Mark notification read
    @Test
    func setNotificationStatus_sendsExpectedRequest() throws {
        sut.updateNotification(status: .read, for: "1") { }
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/uns/v1/notifications/1/status")
        #expect(mockAPI._receivedSendRequest?.method == .patch)
        let body = try #require(mockAPI._receivedSendRequest?.body as? GOVRequest.UpdateBody)
        #expect(body.status == .read)
    }

    @Test
    func setNotificationStatus_success_returns() async {
        mockAPI._stubbedSendResponse = .success(Data())
        await withCheckedContinuation { continuation in
            sut.updateNotification(status: .read, for: "1")  {
                continuation.resume()
            }
        }
    }

    @Test
    func setNotificationStatus_failure_returns() async {
        mockAPI._stubbedSendResponse = .failure(NotificationCentreError.apiUnavailable)
        await withCheckedContinuation { continuation in
            sut.updateNotification(status: .read, for: "1")  {
                continuation.resume()
            }
        }
    }

    // MARK: - Delete notification

    @Test
    func deleteNotification_sendsExpectedRequest() throws {
        sut.deleteNotification(with: "1") { }
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/uns/v1/notifications/1")
        #expect(mockAPI._receivedSendRequest?.method == .delete)
    }

    @Test
    func deleteNotification_success_returns() async {
        mockAPI._stubbedSendResponse = .success(Data())
        await withCheckedContinuation { continuation in
            sut.deleteNotification(with: "1") {
                continuation.resume()
            }
        }
    }

    @Test
    func deleteNotification_failure_returns() async {
        mockAPI._stubbedSendResponse = .failure(NotificationCentreError.apiUnavailable)
        await withCheckedContinuation { continuation in
            sut.deleteNotification(with: "1")  {
                continuation.resume()
            }
        }
    }
}

private extension NotificationCentreServiceClientTests {
    static let multipleNotificationsData =
    """
    [
        {
            "NotificationID": "1234",
            "NotificationTitle": "Title1",
            "NotificationBody": "Body1",
            "DispatchedDateTime": "2026-06-11T10:24:03.000Z",
            "Status": "UNREAD",
            "MessageTitle": "MessageTitle1",
            "MessageBody": "MessageBody1",
            "Metadata": {
                "Sender": {
                    "DisplayName" : "Test"
                }
            }
        },
        {
            "NotificationID": "2345",
            "NotificationTitle": "Title2",
            "NotificationBody": "Body2",
            "DispatchedDateTime": "2026-06-10T10:24:03.000Z",
            "Status": "UNREAD",
            "MessageTitle": "MessageTitle2",
            "MessageBody": "MessageBody2",
            "Metadata": {
                "Sender": {
                    "DisplayName" : "Test"
                }
            }
        }
    ]
    """.data(using: .utf8)!

    static let singleNotificationData =
    """
    {
        "NotificationID": "1234",
        "NotificationTitle": "Title1",
        "NotificationBody": "Body1",
        "DispatchedDateTime": "2026-06-11T10:24:03.000Z",
        "Status": "UNREAD",
        "MessageTitle": "MessageTitle1",
        "MessageBody": "MessageBody1",
        "Metadata": {
            "Sender": {
                "DisplayName" : "Test"
            }
        }
    }
    """.data(using: .utf8)!
}
