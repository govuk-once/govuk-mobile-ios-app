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
            firebaseIDsService: MockFirebaseIDsService()
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
            firebaseIDsService: MockFirebaseIDsService(),
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
            firebaseIDsService: MockFirebaseIDsService(),
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
    func qualtricProperties_refreshedForEachEvent() async throws {
        let mockQualtrics = MockQualtricsWrapper()
        let expectedAppId = "123"
        let expectedSessionId = "321"
        let sut = QualtricsService(
            brandId: "",
            projectId: "",
            qualtrics: mockQualtrics,
            firebaseIDsService: MockFirebaseIDsService()
        )

        sut.evaluateViewEvent(
            screenName: "test_screen",
            params: ["screen_class": "test_class"]
        )

        #expect(mockQualtrics.properties.count == 14)
        for property in mockQualtrics.properties {
            switch property.key {
            case "screen_class":
                #expect(property.value == "test_class")
            case "fb_user_pseudo_id":
                #expect(property.value == expectedAppId)
            case "fb_session_id":
                #expect(property.value == "\(expectedSessionId)")
            default:
                #expect(property.value == "")
            }
        }

        sut.evaluateClickEvent(params: ["text": "Give feedback",
                                        "url": "http://www.example.com"])

        #expect(mockQualtrics.properties.count == 14)
        for property in mockQualtrics.properties {
            switch property.key {
            case "text":
                #expect(property.value == "Give feedback")
            case "url":
                #expect(property.value == "http://www.example.com")
            case "fb_user_pseudo_id":
                #expect(property.value == expectedAppId)
            case "fb_session_id":
                #expect(property.value == "\(expectedSessionId)")
            default:
                #expect(property.value == "")
            }
        }
    }

    @Test
    @MainActor
    func qualtricProperties_sendFirebaseIds() async throws {
        let mockQualtrics = MockQualtricsWrapper()
        let expectedAppId = "123"
        let expectedSessionId = "321"
        let sut = QualtricsService(
            brandId: "",
            projectId: "",
            qualtrics: mockQualtrics,
            firebaseIDsService: MockFirebaseIDsService()
        )

        sut.evaluateViewEvent(
            screenName: "test_screen",
            params: ["screen_class": "test_class"]
        )

        #expect(mockQualtrics.properties.count == 14)
        for property in mockQualtrics.properties {
            switch property.key {
            case "screen_class":
                #expect(property.value == "test_class")
            case "fb_user_pseudo_id":
                #expect(property.value == expectedAppId)
            case "fb_session_id":
                #expect(property.value == "\(expectedSessionId)")
            default:
                #expect(property.value == "")
            }
        }
    }

    @Test
    @MainActor
    func evaluateViewEvent_refreshesSessionID() async throws {
        let mockFirebaseIDsService = MockFirebaseIDsService()
        let sut = QualtricsService(
            brandId: "",
            projectId: "",
            qualtrics: MockQualtricsWrapper(),
            firebaseIDsService: mockFirebaseIDsService
        )

        #expect(mockFirebaseIDsService._updateSessionIDCalled == false)
        sut.evaluateViewEvent(
            screenName: "test_screen",
            params: ["screen_class": "test_class"]
        )
        #expect(mockFirebaseIDsService._updateSessionIDCalled == true)
    }
}
