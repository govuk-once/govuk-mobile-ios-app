import Foundation
import UIKit
import Testing
import Combine

@testable import govuk_ios

@Suite(.serialized)
class NotificationCentreDetailViewModelTests {
    var SUT: NotificationCentreDetailViewModel!

    let mockNotificationCentreService: MockNotificationCentreService!
    let mockAnalyticsService: MockAnalyticsService!


    var _showNotificationActionID: String?

    let testNotificationId = NotificationCentreViewModel.MockData
        .recentNotifications.first!.id

    let mockNotification = NotificationCentreViewModel.MockData
        .recentNotifications.first!

    let testUrl = URL(string:"https://gds.test")!

    var _showUrlActionFired: URL?
    var _onUnreadActionFired: Bool?
    var _onDeleteActionFired: Bool?
    init() {
        mockNotificationCentreService = .init()
        mockAnalyticsService = .init()

        SUT = NotificationCentreDetailViewModel(
            notificationId: testNotificationId,
            notificationService: mockNotificationCentreService,
            analyticsService: mockAnalyticsService,
            actions: .init(
                showUrlAction: {
                    self._showUrlActionFired = $0
                },
                onUnreadAction: {
                    self._onUnreadActionFired = true
                },
                onDeleteAction: {
                    self._onDeleteActionFired = true
                }
            )
        )
    }

    @Test
    func idleState_isLoading() {
        #expect(SUT.state == .new)
    }

    @Test
    func viewAppear_triggersFetch() async {
        mockNotificationCentreService._stubbedFetchNotificationResult = .success(mockNotification)

        await withCheckedContinuation { continuation in
            mockNotificationCentreService._onFetchNotificationCalled = { continuation.resume() }
            SUT.onViewAppear()
        }
    }

    @Test
    func fetchComplete_withNotification_setsStateLoaded() async {
        mockNotificationCentreService._stubbedFetchNotificationResult = .success(mockNotification)

        var subscription: AnyCancellable?
        await withCheckedContinuation { continuation in
            subscription = SUT.$state
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { state in
                if case .loading = state { return }
                if case .new = state { return }
                continuation.resume()
                subscription?.cancel()
            })

            SUT.onViewAppear()
        }

        if case let .loaded(notification, _) = SUT.state {
            #expect(notification == NotificationCentreDetailViewModel
                .NotificationDetailContent(notification: mockNotification))
        } else {
            Issue.record("Failed to load notification")
        }
    }

    @Test
    func fetchComplete_withoutNotification_setsError() async {
        mockNotificationCentreService._stubbedFetchNotificationResult = .success(nil)

        var subscription: AnyCancellable?
        await withCheckedContinuation { continuation in
            subscription = SUT.$state
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { state in
                if case .loading = state { return }
                if case .new = state { return }
                continuation.resume()
                subscription?.cancel()
            })

            SUT.onViewAppear()
        }

        #expect(SUT.state == .error)
    }

    @Test
    func fetchComplete_withNetworkUnavailable_setsNoInternet() async {
        mockNotificationCentreService._stubbedFetchNotificationResult = .failure(.networkUnavailable)

        var subscription: AnyCancellable?
        await withCheckedContinuation { continuation in
            subscription = SUT.$state
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { state in
                if case .loading = state { return }
                if case .new = state { return }
                continuation.resume()
                subscription?.cancel()
            })

            SUT.onViewAppear()
        }

        #expect(SUT.state == .noInternet)
    }

    @Test
    func fetchComplete_withOtherError_setsError() async {
        mockNotificationCentreService._stubbedFetchNotificationResult = .failure(.decodingError)

        var subscription: AnyCancellable?
        await withCheckedContinuation { continuation in
            subscription = SUT.$state
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { state in
                if case .loading = state { return }
                if case .new = state { return }
                continuation.resume()
                subscription?.cancel()
            })

            SUT.onViewAppear()
        }

        #expect(SUT.state == .error)
    }

    @Test
    func onDelete_withNotification_setsStateLoaded_showDeleteConfirm() async {
        mockNotificationCentreService._stubbedFetchNotificationResult = .success(mockNotification)

        var subscription: AnyCancellable?
        await withCheckedContinuation { continuation in
            subscription = SUT.$state.dropFirst(2) // Skip over new and loading
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { state in
                    if case .loaded(_, false) = state { // Ignore the first loaded
                        self.SUT.onDelete()
                        return
                    }
                continuation.resume()
                subscription?.cancel()
            })

            SUT.onViewAppear()
        }

        if case let .loaded(notification, showDeleteConfirm) = SUT.state {
            #expect(notification == NotificationCentreDetailViewModel
                .NotificationDetailContent(notification: mockNotification))
            #expect(showDeleteConfirm == true)
            #expect(_onDeleteActionFired == nil)
            #expect(mockNotificationCentreService._deleteCalledWithId == nil)
        } else {
            Issue.record("Failed to load notification")
        }
    }

    @Test
    func onConfirmDelete_callsService_sendsAction() async {
        mockNotificationCentreService._stubbedFetchNotificationResult = .success(mockNotification)

        var subscription: AnyCancellable?
        await withCheckedContinuation { continuation in
            mockNotificationCentreService._onDeleteCalled = {
                continuation.resume()
                subscription?.cancel()
            }
            subscription = SUT.$state.dropFirst(2) // Skip over new and loading
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { state in
                    if case .loaded(_, false) = state { // Ignore the first loaded
                        self.SUT.onDelete()
                        return
                    }

                    if case .loaded(_, true) = state {
                        self.SUT.onConfirmDelete()
                    }
            })

            SUT.onViewAppear()
        }

        #expect(mockNotificationCentreService._deleteCalledWithId == testNotificationId)
        #expect(_onDeleteActionFired == true)
    }

    @Test
    func onMarkUnread_callsService_sendsAction() async {
        mockNotificationCentreService._stubbedFetchNotificationResult = .success(mockNotification)

        var subscription: AnyCancellable?
        await withCheckedContinuation { continuation in
            mockNotificationCentreService._onMarkUnreadCalled = {
                continuation.resume()
                subscription?.cancel()
            }
            subscription = SUT.$state.dropFirst(2) // Skip over new and loading
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { state in
                    if case .loaded(_, _) = state { // Ignore the first loaded
                        self.SUT.onMarkUnread()
                    }
            })

            SUT.onViewAppear()
        }

        #expect(mockNotificationCentreService._markUnreadCalledWithId == testNotificationId)
        #expect(_onUnreadActionFired == true)
    }

    @Test
    func onShowUrl_sendsAction() async {
        SUT.show(url: testUrl)

        #expect(_showUrlActionFired == testUrl)
    }
}
