import Foundation
import FirebaseAppCheck
import Testing

import FirebaseAnalytics
import GovKit

@testable import govuk_ios

@Suite(.serialized)
struct FirebaseClientTests {

    @Test
    func launch_configuresFirebaseApp() {
        let mockApp = MockFirebaseApp.self
        let mockAnalytics = MockFirebaseAnalytics.self
        let sut = FirebaseClient(
            firebaseApp: mockApp,
            firebaseAnalytics: mockAnalytics,
            firebaseIDsService: MockFirebaseIDsService()
        )

        MockFirebaseApp._configureCalled = false
        sut.launch()

        #expect(mockApp._configureCalled)
    }

    @Test
    func setEnabled_true_enablesAnalytics() {
        let mockApp = MockFirebaseApp.self
        let mockAnalytics = MockFirebaseAnalytics.self
        let sut = FirebaseClient(
            firebaseApp: mockApp,
            firebaseAnalytics: mockAnalytics,
            firebaseIDsService: MockFirebaseIDsService()
        )

        mockAnalytics.clearValues()
        sut.setEnabled(enabled: true)

        #expect(mockAnalytics._setAnalyticsCollectionEnabledReveivedEnabled == true)
    }

    @Test
    func setEnabled_false_disablesAnalytics() {
        let mockApp = MockFirebaseApp.self
        let mockAnalytics = MockFirebaseAnalytics.self
        let sut = FirebaseClient(
            firebaseApp: mockApp,
            firebaseAnalytics: mockAnalytics,
            firebaseIDsService: MockFirebaseIDsService()
        )

        mockAnalytics.clearValues()
        sut.setEnabled(enabled: false)

        #expect(mockAnalytics._setAnalyticsCollectionEnabledReveivedEnabled == false)
    }

    @Test
    func trackEvent_noAdditionalParams_tracksExpectedEvent() {
        let mockApp = MockFirebaseApp.self
        let mockAnalytics = MockFirebaseAnalytics.self
        let sut = FirebaseClient(
            firebaseApp: mockApp,
            firebaseAnalytics: mockAnalytics,
            firebaseIDsService: MockFirebaseIDsService()
        )
        let expectedName = UUID().uuidString
        let expectedEvent = AppEvent(
            name: expectedName,
            params: nil
        )
        sut.track(event: expectedEvent)

        #expect(mockAnalytics._logEventReceivedEventName == expectedName)
        let receivedParams = mockAnalytics._logEventReceivedEventParameters
        #expect(receivedParams?.count == 2)
        #expect(receivedParams?["fb_session_id"] as? String == "321")
        #expect(receivedParams?["fb_user_pseudo_id"] as? String == "123")
    }

    @Test
    func trackEvent_withAdditionalParams_tracksExpectedEvent() {
        let mockApp = MockFirebaseApp.self
        let mockAnalytics = MockFirebaseAnalytics.self
        let sut = FirebaseClient(
            firebaseApp: mockApp,
            firebaseAnalytics: mockAnalytics,
            firebaseIDsService: MockFirebaseIDsService()
        )
        let expectedName = UUID().uuidString
        let expectedValue = UUID().uuidString
        let expectedParams: [String: Any] = [
            "test_param": expectedValue
        ]
        let expectedEvent = AppEvent(
            name: expectedName,
            params: expectedParams
        )

        mockAnalytics.clearValues()
        sut.track(event: expectedEvent)

        #expect(mockAnalytics._logEventReceivedEventName == expectedName)
        let receivedParams = mockAnalytics._logEventReceivedEventParameters
        #expect(receivedParams?.count == 3)
        #expect(receivedParams?["test_param"] as? String == expectedValue)
        #expect(receivedParams?["fb_session_id"] as? String == "321")
        #expect(receivedParams?["fb_user_pseudo_id"] as? String == "123")
    }

    @Test
    @MainActor
    func trackScreen_tracksExpectedEvent() {
        let mockApp = MockFirebaseApp.self
        let mockAnalytics = MockFirebaseAnalytics.self
        let sut = FirebaseClient(
            firebaseApp: mockApp,
            firebaseAnalytics: mockAnalytics,
            firebaseIDsService: MockFirebaseIDsService()
        )
        let expectedScreen = MockBaseViewController(analyticsService: MockAnalyticsService())
        let expectedTitle = UUID().uuidString
        expectedScreen.title = expectedTitle
        mockAnalytics.clearValues()
        sut.track(screen: expectedScreen)

        #expect(mockAnalytics._logEventReceivedEventName == AnalyticsEventScreenView)
        let receivedParams = mockAnalytics._logEventReceivedEventParameters
        #expect(receivedParams?.count == 7)
        #expect(receivedParams?[AnalyticsParameterScreenName] as? String == expectedScreen.trackingName)
        #expect(receivedParams?[AnalyticsParameterScreenClass] as? String == expectedScreen.trackingClass)
        #expect(receivedParams?["screen_title"] as? String == expectedTitle)
        #expect(receivedParams?["language"] as? String == expectedScreen.trackingLanguage)
        #expect(receivedParams?["test_param"] as? String
                == expectedScreen.additionalParameters["test_param"] as? String)
        #expect(receivedParams?["fb_session_id"] as? String == "321")
        #expect(receivedParams?["fb_user_pseudo_id"] as? String == "123")
    }

    @Test
    @MainActor
    func setUserProperty_setsProperty() {
        let mockApp = MockFirebaseApp.self
        let mockAnalytics = MockFirebaseAnalytics.self
        let sut = FirebaseClient(
            firebaseApp: mockApp,
            firebaseAnalytics: mockAnalytics,
            firebaseIDsService: MockFirebaseIDsService()
        )
        let expectedName = UUID().uuidString
        let expectedValue = UUID().uuidString
        sut.set(
            userProperty: .init(key: expectedName, value: expectedValue)
        )

        #expect(mockAnalytics._setUserPropertyReveivedName == expectedName)
        #expect(mockAnalytics._setUserPropertyReveivedValue == expectedValue)
    }

    @Test
    func trackError_doesNothing() {
        let mockApp = MockFirebaseApp.self
        mockApp._clearValues()
        let mockAnalytics = MockFirebaseAnalytics.self
        mockAnalytics.clearValues()

        let sut = FirebaseClient(
            firebaseApp: mockApp,
            firebaseAnalytics: mockAnalytics,
            firebaseIDsService: MockFirebaseIDsService()
        )
        let error = NSError(domain: "test", code: 1)
        sut.track(error: error)

        #expect(mockApp._configureCalled == false)
        #expect(mockAnalytics._setUserPropertyReveivedName == nil)
        #expect(mockAnalytics._setUserPropertyReveivedValue == nil)
    }

}
