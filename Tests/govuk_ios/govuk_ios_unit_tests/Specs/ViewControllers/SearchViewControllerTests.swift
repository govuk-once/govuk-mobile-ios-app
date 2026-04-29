import UIKit
import Foundation
import Testing

import FactoryKit


@testable import govuk_ios

@MainActor
@Suite
struct SearchViewControllerTests {

    @Test
    func viewDidAppear_tracksScreen() async {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = SearchViewModel(
            analyticsService: mockAnalyticsService,
            searchService: MockSearchService(),
            activityService: MockActivityService(context: coreData.viewContext),
            urlOpener: MockURLOpener(),
            openAction: { _ in }
        )
        let subject = SearchViewController(
            viewModel: viewModel,
            searchBar: UISearchBar()
        )
        subject.viewDidAppear(false)

        let screens = mockAnalyticsService._trackScreenReceivedScreens
        #expect(screens.count == 1)
        #expect(screens.first?.trackingName == subject.trackingName)
        #expect(screens.first?.trackingClass == subject.trackingClass)
    }
}
