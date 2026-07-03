import Foundation
import Testing

@testable import govuk_ios

@Suite
final class NotificationCentreServiceTests {
    var mockNotificationCentreServiceClient: MockNotificationCentreServiceClient!
    var mockNotificationCentreRepository: MockNotificationCentreRepository!
    var SUT: NotificationCentreService!

    init() {
        mockNotificationCentreServiceClient = .init()
        mockNotificationCentreRepository = .init()

        SUT = .init(
            serviceClient: mockNotificationCentreServiceClient,
            repository: mockNotificationCentreRepository)
    }

    // MARK: - Fetch all

    @Test
    func fetchNotifications_hitsRepo_returnsExpectedValue() async throws {
        mockNotificationCentreRepository
            ._fetchAllResponse = NotificationCentreViewModel.MockData.recentNotifications

        let result = await withCheckedContinuation { continuation in
            SUT.fetchNotifications(callback: {
                continuation.resume(returning: $0)
            })
        }

        let response = try #require(try? result.get())
        #expect(response.count == 7)
    }

    @Test
    func fetchNotifications_missRepo_hitsClient_returnsExpectedValue() async throws {
        mockNotificationCentreRepository
            ._fetchAllResponse = []

        mockNotificationCentreServiceClient
            ._fetchNotificationsResult =
            .success(NotificationCentreViewModel.MockData.olderNotifications)

        let result = await withCheckedContinuation { continuation in
            SUT.fetchNotifications(callback: {
                continuation.resume(returning: $0)
            })
        }

        let response = try #require(try? result.get())
        #expect(response.count == 4)
    }

    @Test
    func fetchNotifications_missRepo_hitsClient_returnsError() async throws {
        mockNotificationCentreRepository
            ._fetchAllResponse = []

        mockNotificationCentreServiceClient
            ._fetchNotificationsResult =
            .failure(.apiUnavailable)

        let result = await withCheckedContinuation { continuation in
            SUT.fetchNotifications(callback: {
                continuation.resume(returning: $0)
            })
        }

        let fetchError = try #require(result.getError())
        #expect(fetchError == .apiUnavailable)
    }

    // MARK: - Fetch single

    @Test
    func fetchSingleNotification_hitsRepo_returnsExpectedValue() async throws {
        mockNotificationCentreRepository
            ._fetchNotificationResponse = NotificationCentreViewModel
            .MockData.recentNotifications.first

        let result = await withCheckedContinuation { continuation in
            SUT.fetchNotification(with: "1", callback: {
                continuation.resume(returning: $0)
            })
        }

        let response = try #require(try? result.get())
        #expect(response.id == "1")
        #expect(response.body == "Body 1")
        // Have deliberately excluded the rest of the properties as they're long strings
        // and would make the assertions messy
        #expect(response.status == "UNREAD")
    }

    @Test
    func fetchSingleNotification_missRepo_hitsClient_returnsExpectedValue() async throws {
        mockNotificationCentreRepository
            ._fetchNotificationResponse = nil

        mockNotificationCentreServiceClient
            ._fetchNotificationResult = .success(NotificationCentreViewModel
                .MockData.recentNotifications[1])


        let result = await withCheckedContinuation { continuation in
            SUT.fetchNotification(with: "2", callback: {
                continuation.resume(returning: $0)
            })
        }

        let response = try #require(try? result.get())
        #expect(response.id == "2")
        #expect(response.title == "Test 2")
    }

    @Test
    func fetchSingleNotification_missRepo_hitsClient_returnsError() async throws {
        mockNotificationCentreRepository
            ._fetchNotificationResponse = nil

        mockNotificationCentreServiceClient
            ._fetchNotificationResult =
            .failure(.apiUnavailable)

        let result = await withCheckedContinuation { continuation in
            SUT.fetchNotification(with: "1", callback: {
                continuation.resume(returning: $0)
            })
        }

        let fetchError = try #require(result.getError())
        #expect(fetchError == .apiUnavailable)
    }

    // MARK: - Mark read
    @Test
    func markNotificationRead_updatesRepo_makesApiCall() async throws {
        SUT.markRead(with: "1")

        #expect(mockNotificationCentreRepository._didUpdateNotificationId == "1")
        #expect(mockNotificationCentreRepository._didUpdateNotificationUnread == false)

        #expect(mockNotificationCentreServiceClient._didUpdateNotificationID == "1")
        #expect(mockNotificationCentreServiceClient._didUpdateNotificationStatus == .read)
    }

    // MARK: - Mark unread

    @Test
    func markNotificationUnRead_updatesRepo_makesApiCall() async throws {
        SUT.markUnread(with: "2")

        #expect(mockNotificationCentreRepository._didUpdateNotificationId == "2")
        #expect(mockNotificationCentreRepository._didUpdateNotificationUnread == true)

        #expect(mockNotificationCentreServiceClient._didUpdateNotificationID == "2")
        #expect(mockNotificationCentreServiceClient._didUpdateNotificationStatus == .unread)
    }

    // MARK: - Delete

    @Test
    func deleteNotification_updatesRepo_makesApiCall() async throws {
        SUT.delete(with: "3")

        #expect(mockNotificationCentreRepository._didDeleteNotificationId == "3")

        #expect(mockNotificationCentreServiceClient._didDeleteNotificationId == "3")
    }
}
