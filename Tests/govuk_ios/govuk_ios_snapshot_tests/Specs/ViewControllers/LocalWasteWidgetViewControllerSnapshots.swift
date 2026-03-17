import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class LocalWasteWidgetViewControllerSnapshots: SnapshotTestCase {

    private var service: MockLocalWasteService!
    private var viewModel: LocalWasteWidgetViewModel!

    override func setUp() async throws {
        try await super.setUp()

        service = MockLocalWasteService()
        service._dataFetchAddress = Constants.address

        viewModel = LocalWasteWidgetViewModel(
            service: service)
    }

    func test_loadInNavigationController_light_rendersCorrectly() async throws {
        service._dataFetchSchedule = Constants.schedule

        await viewModel.load()

        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() async throws {
        service._dataFetchSchedule = Constants.schedule

        await viewModel.load()

        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_light_error_rendersCorrectly() async throws {
        service._errorFetchSchedule = LocalWasteScheduleApiError.apiUnavailable

        await viewModel.load()

        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_dark_error_rendersCorrectly() async throws {
        service._errorFetchSchedule = LocalWasteScheduleApiError.apiUnavailable

        await viewModel.load()

        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_light_empty_rendersCorrectly() async throws {
        service._dataFetchSchedule = []

        await viewModel.load()

        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_dark_empty_rendersCorrectly() async throws {
        service._dataFetchSchedule = []

        await viewModel.load()

        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    private func viewController() -> UIViewController {
        let view = LocalWasteWidgetView(
            viewModel: viewModel
        )
        return HostingViewController(rootView: view)
    }

    enum Constants {
        static func today() -> Date {
            Calendar.current.startOfDay(for: Date())
        }

        static let address: LocalWasteAddress =
            .init(
                addressFull: "1, MALPASS COURT, BS15 3LL",
                uprn: "the-uprn",
                localCustodianCode: "the-code")
        static let schedule: [LocalWasteBin] = [
            .init(date: today(),
                  name: "General Waste",
                  color: .black,
                  content: "All waste"),
            .init(date: today(),
                  name: "Paper",
                  color: .blue,
                  content: "Paper, cardboard"),
            .init(date: today(),
                  name: "Plastics",
                  color: nil,
                  content: "Hard plastics only")
        ]
    }
}
