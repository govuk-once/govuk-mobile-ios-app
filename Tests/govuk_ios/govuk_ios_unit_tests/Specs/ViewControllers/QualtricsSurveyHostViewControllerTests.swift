import Foundation
import UIKit
import Testing

@testable import govuk_ios

@Suite(.serialized)
@MainActor
struct QualtricsSurveyHostViewControllerTests {

    @Test
    func viewDidLoad_embedsSurveyViewController() {
        let surveyViewController = UIViewController()
        let sut = QualtricsSurveyHostViewController(
            surveyViewController: surveyViewController,
            notificationCenter: MockNotificationCenter()
        )

        sut.loadViewIfNeeded()

        #expect(sut.modalPresentationStyle == .overFullScreen)
        #expect(sut.children.first === surveyViewController)
        #expect(surveyViewController.view.superview === sut.view)
        #expect(sut.childForStatusBarStyle === surveyViewController)
    }

    @Test
    func surveyDismissingItself_postsSurveyDismissed() async throws {
        let mockNotificationCenter = MockNotificationCenter()
        let surveyViewController = UIViewController()
        let sut = QualtricsSurveyHostViewController(
            surveyViewController: surveyViewController,
            notificationCenter: mockNotificationCenter
        )
        let window = try makeWindow()
        defer { window.isHidden = true }
        let presenter = try #require(window.rootViewController)

        await present(sut, from: presenter)
        #expect(mockNotificationCenter._receivedPostNames.isEmpty)

        await withCheckedContinuation { continuation in
            surveyViewController.dismiss(animated: false) {
                continuation.resume()
            }
        }

        #expect(mockNotificationCenter._receivedPostNames == [.qualtricsSurveyDismissed])
    }

    @Test
    func presentingOverSurvey_doesNotPostSurveyDismissed() async throws {
        let mockNotificationCenter = MockNotificationCenter()
        let sut = QualtricsSurveyHostViewController(
            surveyViewController: UIViewController(),
            notificationCenter: mockNotificationCenter
        )
        let window = try makeWindow()
        defer { window.isHidden = true }
        let presenter = try #require(window.rootViewController)
        await present(sut, from: presenter)

        let overlay = UIViewController()
        overlay.modalPresentationStyle = .fullScreen
        await present(overlay, from: sut)

        #expect(mockNotificationCenter._receivedPostNames.isEmpty)
    }

    private func makeWindow() throws -> UIWindow {
        let scene = try #require(
            UIApplication.shared.connectedScenes.first as? UIWindowScene
        )
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIViewController()
        window.isHidden = false
        return window
    }

    private func present(_ viewController: UIViewController,
                         from presenter: UIViewController) async {
        await withCheckedContinuation { continuation in
            presenter.present(viewController, animated: false) {
                continuation.resume()
            }
        }
    }
}
