import Foundation
import UIKit
import LocalAuthentication
import GovKit

protocol InactivityServiceInterface {
    func startMonitoring(inactivityHandler: @escaping () -> Void,
                         alertHandler: @escaping () -> Void)
    func resetTimers()
}

class InactivityService: InactivityServiceInterface {
    private let timer: TimerWrapperInterface
    private let warningTimer: TimerWrapperInterface
    private let authenticationService: AuthenticationServiceInterface
    private let inactivityThreshold = Constants.Timers.Thresholds.inactivityTimeout // 15 minutes
    private let warningThreshold = Constants.Timers.Thresholds.inactivityWarning // 13 minutes
    private var inAppTimer: Timer?
    private var alertTimer: Timer?
    private var inactivityHandler: (() -> Void)?
    private var alertHandler: (() -> Void)?
    var backgroundedTime: Date = Date()

    private var inactive: Bool {
        let currentTime = Date()
        let inactivityDuration = currentTime.timeIntervalSince(backgroundedTime)
        return inactivityDuration >= inactivityThreshold
    }

    init(authenticationService: AuthenticationServiceInterface,
         timer: TimerWrapperInterface,
         warningTimer: TimerWrapperInterface) {
        self.authenticationService = authenticationService
        self.warningTimer = warningTimer
        self.timer = timer
        registerObservers()
    }

    func startMonitoring(inactivityHandler: @escaping () -> Void,
                         alertHandler: @escaping () -> Void) {
        self.inactivityHandler = inactivityHandler
        self.alertHandler = alertHandler
        resetTimers()
    }

    func resetTimers() {
        guard self.authenticationService.isSignedIn else {
            return
        }

        inAppTimer?.invalidate()
        alertTimer?.invalidate()
        inAppTimer = timer.scheduledTimer(withTimeInterval: inactivityThreshold,
                                          repeats: false) { [weak self] _ in
            self?.inactivityHandler?()
        }
        alertTimer = warningTimer.scheduledTimer(withTimeInterval: warningThreshold,
                                           repeats: false) { [weak self] _ in
            self?.alertHandler?()
        }
    }

    private func registerObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appInteraction),
            name: UIAccessibility.elementFocusedNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appInteraction),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appInteraction),
            name: UITextField.textDidChangeNotification,
            object: nil
        )
    }

    @objc private func appDidEnterBackground() {
        inAppTimer?.invalidate()
        alertTimer?.invalidate()
        backgroundedTime = Date()
    }

    @objc private func appWillEnterForeground() {
        guard authenticationService.isSignedIn else {
            return
        }

        if inactive {
            inactivityHandler?()
            resetTimers()
        }
    }

    @objc private func appInteraction() {
        resetTimers()
    }
}
