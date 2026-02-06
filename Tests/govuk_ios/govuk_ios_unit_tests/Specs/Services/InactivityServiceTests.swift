import Foundation
import UIKit
import Testing

@testable import govuk_ios

@Suite
class InactivityServiceTests {
    @Test
    func startMonitoring_setsUpTimers() {
        let mockTimer = MockTimerWrapper()
        let mockWarningTimer = MockTimerWrapper()
        let mockAuthService = MockAuthenticationService()
        mockAuthService._stubbedIsSignedIn = true
        let sut = InactivityService(authenticationService: mockAuthService,
                                    timer: mockTimer,
                                    warningTimer: mockWarningTimer)

        sut.startMonitoring(
            inactivityHandler: {},
            alertHandler: {}
        )
        #expect(mockTimer.lastCreatedTimer != nil)
        #expect(mockTimer.lastCreatedTimer?.interval == 900)
        #expect(mockWarningTimer.lastCreatedTimer != nil)
        #expect(mockWarningTimer.lastCreatedTimer?.interval == 780)
    }

    @Test
    func startMonitoring_callsHandlers() {
        let mockTimer = MockTimerWrapper()
        let mockWarningTimer = MockTimerWrapper()
        let mockAuthService = MockAuthenticationService()
        mockAuthService._stubbedIsSignedIn = true
        let sut = InactivityService(authenticationService: mockAuthService,
                                    timer: mockTimer,
                                    warningTimer: mockWarningTimer)
        var handlerCalled = false
        var alertHandlerCalled = false
        sut.startMonitoring(
            inactivityHandler: { handlerCalled = true },
            alertHandler: { alertHandlerCalled = true }
        )

        #expect(!handlerCalled)
        mockTimer.lastCreatedTimer?.fire()
        #expect(handlerCalled)

        #expect(!alertHandlerCalled)
        mockWarningTimer.lastCreatedTimer?.fire()
        #expect(alertHandlerCalled)
    }

    @Test
    func resetTimer_invalidatesExistingTimersAndCreatesNew() {
        let mockTimer = MockTimerWrapper()
        let mockWarningTimer = MockTimerWrapper()
        let mockAuthService = MockAuthenticationService()
        mockAuthService._stubbedIsSignedIn = true
        let sut = InactivityService(authenticationService: mockAuthService,
                                    timer: mockTimer,
                                    warningTimer: mockWarningTimer)
        sut.startMonitoring(
            inactivityHandler: {},
            alertHandler: {}
        )
        let inactivityTimer = mockTimer.lastCreatedTimer
        let warningTimer = mockWarningTimer.lastCreatedTimer
        sut.resetTimers()

        #expect(inactivityTimer!.invalidateCalled)
        #expect(mockTimer.lastCreatedTimer != inactivityTimer)
        #expect(warningTimer!.invalidateCalled)
        #expect(mockWarningTimer.lastCreatedTimer != warningTimer)
    }

    @Test
    func resetTimer_signedOut_doesntInvalidateTimer() {
        let mockTimer = MockTimerWrapper()
        let mockWarningTimer = MockTimerWrapper()
        let mockAuthService = MockAuthenticationService()
        mockAuthService._stubbedIsSignedIn = false
        let sut = InactivityService(authenticationService: mockAuthService,
                                    timer: mockTimer,
                                    warningTimer: mockWarningTimer)
        sut.resetTimers()
        let inactivityTimer = mockTimer.lastCreatedTimer
        let warningTimer = mockWarningTimer.lastCreatedTimer

        #expect(inactivityTimer == nil)
        #expect(warningTimer == nil)
    }

    @Test
    func startMonitoring_appDidEnterBackground_setsBackgroundedTime() {
        let mockTimer = MockTimerWrapper()
        let mockWarningTimer = MockTimerWrapper()
        let mockAuthService = MockAuthenticationService()
        mockAuthService._stubbedIsSignedIn = true
        let sut = InactivityService(authenticationService: mockAuthService,
                                    timer: mockTimer,
                                    warningTimer: mockWarningTimer)
        sut.startMonitoring(
            inactivityHandler: {},
            alertHandler: {}
        )
        let inactivityTimer = mockTimer.lastCreatedTimer
        let warningTimer = mockWarningTimer.lastCreatedTimer

        let initialBackgroundedTime = sut.backgroundedTime
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

        #expect(inactivityTimer!.invalidateCalled)
        #expect(warningTimer!.invalidateCalled)
        #expect(sut.backgroundedTime > initialBackgroundedTime)
    }

    @Test
    func appWillEnterForeground_inactive_callsInactivityHandler() {
        let mockTimer = MockTimerWrapper()
        let mockWarningTimer = MockTimerWrapper()
        let mockAuthService = MockAuthenticationService()
        mockAuthService._stubbedIsSignedIn = true
        let sut = InactivityService(authenticationService: mockAuthService,
                                    timer: mockTimer,
                                    warningTimer: mockWarningTimer)
        var inactivityHandlerCalled = false
        var warningHandlerCalled = false
        sut.startMonitoring(
            inactivityHandler: { inactivityHandlerCalled = true },
            alertHandler: { warningHandlerCalled = true }
        )
        sut.backgroundedTime = Date().addingTimeInterval(-16 * 60)
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        #expect(inactivityHandlerCalled)
        #expect(!warningHandlerCalled)
    }

    @Test
    func appWillEnterForeground_active_doesntCallHandlers() {
        let mockTimer = MockTimerWrapper()
        let mockWarningTimer = MockTimerWrapper()
        let initialTimer = mockTimer.lastCreatedTimer
        let initialWarningTimer = mockWarningTimer.lastCreatedTimer
        let mockAuthService = MockAuthenticationService()
        mockAuthService._stubbedIsSignedIn = true
        let sut = InactivityService(authenticationService: mockAuthService,
                                    timer: mockTimer,
                                    warningTimer: mockWarningTimer)
        var inactivityHandlerCalled = false
        var warningHandlerCalled = false
        sut.startMonitoring(
            inactivityHandler: { inactivityHandlerCalled = true },
            alertHandler: { warningHandlerCalled = true }
        )
        sut.backgroundedTime = Date().addingTimeInterval(-14 * 60)
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        #expect(!inactivityHandlerCalled)
        #expect(!warningHandlerCalled)
        #expect(mockTimer.lastCreatedTimer != initialTimer)
        #expect(mockWarningTimer.lastCreatedTimer != initialWarningTimer)
    }

    @Test
    func appWillEnterForeground_inactive_signedOut_doesntCallHandlers() {
        let mockTimer = MockTimerWrapper()
        let mockWarningTimer = MockTimerWrapper()
        let mockAuthService = MockAuthenticationService()
        mockAuthService._stubbedIsSignedIn = false
        let sut = InactivityService(authenticationService: mockAuthService,
                                    timer: mockTimer,
                                    warningTimer: mockWarningTimer)
        var inactivityHandlerCalled = false
        var warningHandlerCalled = false
        sut.startMonitoring(
            inactivityHandler: { inactivityHandlerCalled = true },
            alertHandler: { warningHandlerCalled = true }
        )
        sut.backgroundedTime = Date().addingTimeInterval(-16 * 60)
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        #expect(!inactivityHandlerCalled)
        #expect(!warningHandlerCalled)
    }

    @Test
    func appInteraction_resetsTimers() {
        let mockTimer = MockTimerWrapper()
        let mockWarningTimer = MockTimerWrapper()
        var timer = mockTimer.lastCreatedTimer
        var warningTimer = mockWarningTimer.lastCreatedTimer
        let mockAuthService = MockAuthenticationService()
        mockAuthService._stubbedIsSignedIn = true
        let sut = InactivityService(authenticationService: mockAuthService,
                                    timer: mockTimer,
                                    warningTimer: mockWarningTimer)
        sut.startMonitoring(
            inactivityHandler: {},
            alertHandler: {}
        )

        NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
        #expect(mockTimer.lastCreatedTimer != timer)
        #expect(mockWarningTimer.lastCreatedTimer != warningTimer)

        timer = mockTimer.lastCreatedTimer
        warningTimer = mockWarningTimer.lastCreatedTimer
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        #expect(mockTimer.lastCreatedTimer != timer)
        #expect(mockWarningTimer.lastCreatedTimer != warningTimer)

        timer = mockTimer.lastCreatedTimer
        warningTimer = mockWarningTimer.lastCreatedTimer
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: nil)
        #expect(mockTimer.lastCreatedTimer != timer)
        #expect(mockWarningTimer.lastCreatedTimer != warningTimer)
    }
}
