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
                self._showNotificationActionID = $0.id
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
        let testNotification = NotificationCentreViewModel.MockData.testNotifications.recent.first!
        SUT.onTapNotification(
            notification: testNotification)
        #expect(_showNotificationActionID == testNotification.id)
    }

    @Test
    func viewAppear_triggersFetch() async {
        await withCheckedContinuation { continuation in
            mockNotificationCentreService._onFetchNotificationsCalled = { continuation.resume() }
            SUT.onViewAppear()
        }
    }

    @Test
    func fetchComplete_withNotifications_setsStateLoaded() async {
        let recent = NotificationCentreViewModel.MockData.testNotifications.recent
        let older = NotificationCentreViewModel.MockData.testNotifications.older
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
            #expect(notifications.recent == recent)
            #expect(notifications.older == older)
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
