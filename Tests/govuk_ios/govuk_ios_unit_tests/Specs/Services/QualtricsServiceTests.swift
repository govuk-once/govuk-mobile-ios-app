import Foundation
import UIKit
import GovKit
import Qualtrics
import Testing

@testable import govuk_ios

struct QualtricsServiceTests {

    @Test
    func service_does_init() {
        let mockQualtrics = MockQualtricsWrapper()
        _ = QualtricsService(
            brandId: "",
            projectId: "",
            qualtrics: mockQualtrics
        )

        #expect(mockQualtrics._didInitializeProject)
    }

    @Test
    @MainActor
    func evaluateViewEvent_presentsSurveyIfTargetValid() {
        let mockQualtrics = MockQualtricsWrapper()
        let sut = QualtricsService(
            brandId: "",
            projectId: "",
            qualtrics: mockQualtrics,
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
    func evaluateClickEvent_presentsSurveyIfTargetValid() {
        let mockQualtrics = MockQualtricsWrapper()
        let sut = QualtricsService(
            brandId: "",
            projectId: "",
            qualtrics: mockQualtrics,
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
    func qualtricPropertiesRefreshedForEachEvent() {
        let mockQualtrics = MockQualtricsWrapper()
        let sut = QualtricsService(
            brandId: "",
            projectId: "",
            qualtrics: mockQualtrics
        )

        sut.evaluateViewEvent(
            screenName: "test_screen",
            params: ["screen_class": "test_class"]
        )

        #expect(mockQualtrics.properties.count == 12)
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

        #expect(mockQualtrics.properties.count == 12)
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
}
