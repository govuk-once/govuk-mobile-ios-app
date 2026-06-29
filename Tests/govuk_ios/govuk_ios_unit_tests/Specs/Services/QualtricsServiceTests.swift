import Foundation
import UIKit
import GovKit
import Qualtrics
import Testing

@testable import govuk_ios

@Suite(.serialized)
struct QualtricsServiceTests {

    @Test
    func service_does_init() {
        let mockQualtrics = MockQualtricsWrapper()
        _ = QualtricsService(
            brandId: "",
            projectId: "",
            qualtrics: mockQualtrics,
            firebaseAnalytics: MockFirebaseAnalytics.self
        )

        #expect(mockQualtrics._didInitializeProject)
    }

    @Test
    @MainActor
    func evaluateViewEvent_presentsSurveyIfTargetValid() async {
        let mockQualtrics = MockQualtricsWrapper()
        let sut = QualtricsService(
            brandId: "",
            projectId: "",
            qualtrics: mockQualtrics,
            firebaseAnalytics: MockFirebaseAnalytics.self,
            presentationController: UIViewController()
        )

        let targetResult = MockTargetingResult()
        targetResult._stubbedTargetPassed = true
        mockQualtrics._stubbedTargetingResults = ["interceptId": targetResult]
        sut.evaluateViewEvent(
            screenName: "Test screen",
            params: ["test_key": "test_value"]
        )

        #expect(mockQualtrics._didDisplayViewController)
        #expect(mockQualtrics._didRegisterViewVisit)
    }

    @Test
    @MainActor
    func evaluateClickEvent_presentsSurveyIfTargetValid() async {
        let mockQualtrics = MockQualtricsWrapper()
        let sut = QualtricsService(
            brandId: "",
            projectId: "",
            qualtrics: mockQualtrics,
            firebaseAnalytics: MockFirebaseAnalytics.self,
            presentationController: UIViewController()
        )

        let targetResult = MockTargetingResult()
        targetResult._stubbedTargetPassed = true
        targetResult._stubbedSurveyUrl = "http://www.example.com"
        mockQualtrics._stubbedTargetingResults = ["interceptId": targetResult]
        sut.evaluateClickEvent(
            params: ["test_key": "test_value"]
        )

        #expect(targetResult._didRecordImpression)
    }

    @Test
    @MainActor
    func qualtricPropertiesRefreshedForEachEvent() async throws {
        let mockQualtrics = MockQualtricsWrapper()
        let sut = QualtricsService(
            brandId: "",
            projectId: "",
            qualtrics: mockQualtrics,
            firebaseAnalytics: MockFirebaseAnalytics.self
        )

        sut.evaluateViewEvent(
            screenName: "test_screen",
            params: ["screen_class": "test_class"]
        )

        // Delay required to allow for async fetching of sessionID.
        // See QualtricsService.setQualtricsProperties
        try await Task.sleep(for: .seconds(0.1))
        #expect(mockQualtrics.properties.count == 14)
        for property in mockQualtrics.properties {
            switch property.key {
            case "screen_class":
                #expect(property.value == "test_class")
            default:
                #expect(property.value == "")
            }
        }

        sut.evaluateClickEvent(params: ["text": "Give feedback",
                                              "url": "http://www.example.com"])

        // Delay required to allow for async fetching of sessionID.
        // See QualtricsService.setQualtricsProperties
        try await Task.sleep(for: .seconds(0.1))
        #expect(mockQualtrics.properties.count == 14)
        for property in mockQualtrics.properties {
            switch property.key {
            case "text":
                #expect(property.value == "Give feedback")
            case "url":
                #expect(property.value == "http://www.example.com")
            default:
                #expect(property.value == "")
            }
        }
    }

    @Test
    @MainActor
    func qualtricProperties_sendFirebaseIds() async throws {
        let mockQualtrics = MockQualtricsWrapper()
        let expectedSessionId: Int64 = 123
        let expectedAppId = "appId"
        let analtytics = MockFirebaseAnalytics.self
        analtytics._stubbedSessionId = expectedSessionId
        analtytics._stubbedAppInstanceId = expectedAppId
        let sut = QualtricsService(
            brandId: "",
            projectId: "",
            qualtrics: mockQualtrics,
            firebaseAnalytics: analtytics
        )

        sut.evaluateViewEvent(
            screenName: "test_screen",
            params: ["screen_class": "test_class"]
        )

        // Delay required to allow for async fetching of sessionID.
        // See QualtricsService.setQualtricsProperties
        try await Task.sleep(for: .seconds(0.1))
        #expect(mockQualtrics.properties.count == 14)
        for property in mockQualtrics.properties {
            switch property.key {
            case "screen_class":
                #expect(property.value == "test_class")
            case "ga_app_instance_id":
                #expect(property.value == expectedAppId)
            case "ga_session_id":
                #expect(property.value == "\(expectedSessionId)")
            default:
                #expect(property.value == "")
            }
        }
        analtytics._stubbedSessionId = nil
        analtytics._stubbedAppInstanceId = nil

    }
}
