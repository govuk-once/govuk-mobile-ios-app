import Foundation
import UIKit
import Testing
import Combine

@testable import govuk_ios

@Suite(.serialized)
class NotificationCentreViewModelTests {

    class MockDateProvider: NotificationCentreViewModel.DateProvider {
        override var currentDate: Date {
            Date(timeIntervalSince1970: 1772198784) // Fri, 27 Feb 2026 13:26:24 GMT
        }
    }

    var SUT: NotificationCentreViewModel!

    let mockNotificationCentreService: MockNotificationCentreService!
    let mockAnalyticsService: MockAnalyticsService!
    

    var _showNotificationActionID: String?

    init() {
        mockNotificationCentreService = .init()
        mockAnalyticsService = .init()

        SUT = NotificationCentreViewModel(
            actions: .init(showNotification: {
                self._showNotificationActionID = $0
            }),
            notificationCentreService: mockNotificationCentreService,
            analyticsService: mockAnalyticsService,
            dateProvider: MockDateProvider())
    }

    @Test
    func idleState_isLoading() {
        #expect(SUT.state == .loading)
    }

    @Test
    func tapNotification_triggersAction() {
        let testNotification = NotificationCentreViewModel.MockData.recentNotifications.first!
        SUT.onTapNotification(
            notification: testNotification.id)
        #expect(_showNotificationActionID == testNotification.id)
    }

    @Test
    func viewAppear_triggersFetch() async {
        mockNotificationCentreService._stubbedFetchNotificationsResult = .success([])
        await withCheckedContinuation { continuation in
            mockNotificationCentreService._onFetchNotificationsCalled = { continuation.resume() }
            SUT.onViewAppear()
        }

        #expect(mockNotificationCentreService._fetchNotificationsCalled == true)
    }

    @Test
    func fetchComplete_withNotifications_setsStateLoaded() async {
        let recent = NotificationCentreViewModel.MockData.recentNotifications
        let older = NotificationCentreViewModel.MockData.olderNotifications
        let allNotifications = recent + older

        mockNotificationCentreService._stubbedFetchNotificationsResult = .success(allNotifications)

        var subscription: AnyCancellable?
        await withCheckedContinuation { continuation in
            SUT.onViewAppear()

            subscription = SUT.$state
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { state in
                if case .loading = state { return }
                continuation.resume()
                subscription?.cancel()
            })
        }

        if case let .loaded(notifications) = SUT.state {
            #expect(notifications.recent == recent.map { NotificationCentreViewModel.NotificationListItem(notification: $0)})
            #expect(notifications.older == older.map { NotificationCentreViewModel.NotificationListItem(notification: $0)})
        } else {
            Issue.record("Failed to load notifications")
        }
    }

    @Test
    func fetchComplete_withoutNotifications_setsStateEmpty() async {
        mockNotificationCentreService._stubbedFetchNotificationsResult = .success(.init())

        var subscription: AnyCancellable?
        await withCheckedContinuation { continuation in
            SUT.onViewAppear()

            subscription = SUT.$state
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { state in
                if case .loading = state { return }
                continuation.resume()
                subscription?.cancel()
            })
        }

        #expect(SUT.state == .empty)
    }

    @Test
    func fetchComplete_withNetworkUnavailable_setsNoInternet() async {
        mockNotificationCentreService._stubbedFetchNotificationsResult = .failure(.networkUnavailable)

        var subscription: AnyCancellable?
        await withCheckedContinuation { continuation in
            SUT.onViewAppear()

            subscription = SUT.$state
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { state in
                if case .loading = state { return }
                continuation.resume()
                subscription?.cancel()
            })
        }

        #expect(SUT.state == .noInternet)
    }

    @Test
    func fetchComplete_withOtherError_setsError() async {
        mockNotificationCentreService._stubbedFetchNotificationsResult = .failure(.decodingError)

        var subscription: AnyCancellable?
        await withCheckedContinuation { continuation in
            SUT.onViewAppear()

            subscription = SUT.$state
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { state in
                if case .loading = state { return }
                continuation.resume()
                subscription?.cancel()
            })
        }

        #expect(SUT.state == .error)
    }
}
