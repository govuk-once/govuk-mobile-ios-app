import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class LocalWasteScheduleViewControllerSnapshotTests: SnapshotTestCase {

    private var service: MockLocalWasteService!
    private var viewModel: LocalWasteScheduleViewModel!

    override func setUp() async throws {
        try await super.setUp()

        service = MockLocalWasteService()
        service._dataFetchAddress = Constants.address
        service._scheduleCache = Constants.schedule

        viewModel = LocalWasteScheduleViewModel(
            service: service,
            analyticsService: MockAnalyticsService(),
            dismissAction: { }
        )
    }

    func test_loadInNavigationController_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    private func viewController() -> UIViewController {
        let view = LocalWasteScheduleView(
            viewModel: viewModel
        )
        let viewController = HostingViewController(
            rootView: view
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        return viewController
    }

    enum Constants {
        static func tomorrow() -> Date {
            Calendar.current.startOfDay(
                for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            )
        }
        static func dayAfterTomorrow() -> Date {
            Calendar.current.startOfDay(
                for: Calendar.current.date(byAdding: .day, value: 2, to: Date())!
            )
        }

        static let address: LocalWasteAddress =
            .init(
                addressFull: "1, MALPASS COURT, BS15 3LL",
                uprn: "the-uprn",
                localCustodianCode: "the-code")
        static let schedule: [LocalWasteBin] = [
            .init(date: tomorrow(),
                  name: "General Waste",
                  color: .black,
                  content: "All waste"),
            .init(date: tomorrow(),
                  name: "Paper",
                  color: .blue,
                  content: "Paper, cardboard"),
            .init(date: dayAfterTomorrow(),
                  name: "Plastics",
                  color: nil,
                  content: "Hard plastics only")
        ]
    }
}
