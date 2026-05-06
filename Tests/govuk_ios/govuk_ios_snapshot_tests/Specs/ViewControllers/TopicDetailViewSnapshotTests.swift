import Foundation
import XCTest
import UIKit
import SwiftUI
import GovKit

@testable import govuk_ios

@MainActor
class TopicDetailViewSnapshotTests: SnapshotTestCase {
    func test_topicDetail_light_fetching_rendersCorrectly() {
        let mockViewModel = MockTopicDetailViewModel(
            title: "test_title",
            isLoaded: false
        )
        let view = TopicDetailView(
            viewModel: mockViewModel,
            widgetView: nil
        )
        let viewController = HostingViewController(rootView: view)
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light
        )
    }

    func test_topicDetail_dark_fetching_rendersCorrectly() {
        let mockViewModel = MockTopicDetailViewModel(
            title: "test_title",
            isLoaded: false
        )
        let view = TopicDetailView(
            viewModel: mockViewModel,
            widgetView: nil
        )
        let viewController = HostingViewController(rootView: view)
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark
        )
    }

    func test_topicDetail_fetched_rendersCorrectly() {
        let mockViewModel = MockTopicDetailViewModel.arrangeFetched
        let view = TopicDetailView(
            viewModel: mockViewModel,
            widgetView: nil
        )
        let viewController = HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light
        )
    }

    func test_topicDetail_fetched_manyStepBySteps_rendersCorrectly() {
        let mockViewModel = MockTopicDetailViewModel.arrangeManyStepBySteps
        let view = TopicDetailView(
            viewModel: mockViewModel,
            widgetView: nil
        )
        let viewController = HostingViewController(rootView: view)
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light
        )
    }

    func test_topicDetail_dark_rendersCorrectly() {
        let mockViewModel = MockTopicDetailViewModel.arrangeManyStepBySteps
        let view = TopicDetailView(
            viewModel: mockViewModel,
            widgetView: nil
        )
        let viewController = HostingViewController(rootView: view)
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark
        )
    }

    func test_topicDetail_onlySubTopics_rendersCorrectly() {
        let mockViewModel = MockTopicDetailViewModel.arrangeOnlySubtopics
        let view = TopicDetailView(
            viewModel: mockViewModel,
            widgetView: nil
        )
        let viewController = HostingViewController(rootView: view)
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark
        )
    }

    func test_topicDetail_networkUnavailable_rendersCorrectly() {
        let mockViewModel = MockTopicDetailViewModel(
            title: "test_title",
            errorViewModel: .networkUnavailable(action: {})
        )

        let view = TopicDetailView(
            viewModel: mockViewModel,
            widgetView: nil
        )
        let viewController = HostingViewController(rootView: view)
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light
        )
    }
    
    func test_topicDetail_genericError_rendersCorrectly() {
        let mockViewModel = MockTopicDetailViewModel(
            title: "test_title",
            errorViewModel: .topicErrorWithAction({})
        )
        let view = TopicDetailView(
            viewModel: mockViewModel,
            widgetView: nil
        )
        let viewController = HostingViewController(rootView: view)
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light
        )
    }

    func test_stepBySteps_light_rendersCorrectly() {
        let viewModel = MockTopicDetailViewModel.arrangeStepByStep
        let view = TopicDetailView(
            viewModel: viewModel,
            widgetView: nil
        )
        let viewController = HostingViewController(rootView: view)
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light
        )
    }

    func test_stepBySteps_dark_rendersCorrectly() {
        let viewModel = MockTopicDetailViewModel.arrangeStepByStep
        let view = TopicDetailView(
            viewModel: viewModel,
            widgetView: nil
        )
        let viewController = HostingViewController(rootView: view)
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark
        )
    }

    func test_withWidget_light_rendersCorrectly() {
        let mockWidget = Text("Mock Widget")
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color.green)

        let viewModel = MockTopicDetailViewModel.arrangeFetched
        let view = TopicDetailView(
            viewModel: viewModel,
            widgetView: AnyView(mockWidget)
        )
        let viewController = HostingViewController(rootView: view)
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light
        )
    }

    func test_withWidget_dark_rendersCorrectly() {
        let mockWidget = Text("Mock Widget")
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color.green)

        let viewModel = MockTopicDetailViewModel.arrangeFetched
        let view = TopicDetailView(
            viewModel: viewModel,
            widgetView: AnyView(mockWidget)
        )
        let viewController = HostingViewController(rootView: view)
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark
        )
    }
}
