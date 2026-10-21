import Foundation
import CoreData
import Testing
import SwiftUI
import GovKit

@testable import govuk_ios

@MainActor
private final class TestableRecentActivityListViewController: RecentActivityListViewController {
    var stubbedIsLandscapeDuoFoldedOpen: Bool = false
    
    override var isLandscapeDuoFoldedOpen: Bool {
        return stubbedIsLandscapeDuoFoldedOpen
    }
}

@Suite
@MainActor
struct RecentActivityListViewControllerTests {
    
    @Test
    func test_isLandscapeDuoFoldedOpen_withNoWindow_returnsFalse() async {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let mockActivityService = MockActivityService(
            context: coreData.viewContext
        )
        let viewController = RecentActivityListViewController(
            viewModel: .init(
                activityService: mockActivityService,
                analyticsService: MockAnalyticsService(),
                selectedAction: { _ in }
            )
        )
        #expect(!viewController.isLandscapeDuoFoldedOpen)
    }
    
    @Test
    func test_configureTitleConstraints_whenLandscapeDuoFoldedOpenIsFalse_anchorsToViewSides() async {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let mockActivityService = MockActivityService(
            context: coreData.viewContext
        )
        
        _ = ActivityItem.arrange(
            title: "Test 3",
            date: .arrange("10/04/2024"),
            context: coreData.viewContext
        )
        _ = ActivityItem.arrange(
            title: "Test 4",
            date: .arrange("11/04/2024"),
            context: coreData.viewContext
        )
        let request = ActivityItem.fetchRequest()
        let resultsController = NSFetchedResultsController<ActivityItem>(
            fetchRequest: request,
            managedObjectContext: coreData.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? resultsController.performFetch()
        mockActivityService._stubbedFetchResultsController = resultsController
        
        let viewController = TestableRecentActivityListViewController(
            viewModel: .init(
                activityService: mockActivityService,
                analyticsService: MockAnalyticsService(),
                selectedAction: { _ in }
            )
        )
        viewController.stubbedIsLandscapeDuoFoldedOpen = false
        _ = viewController.view
        let constraints = viewController.view.constraints
        let leadingConstraint = constraints.first { constraint in
            let isTitleLeading = constraint.firstAttribute == .leading
            let isViewLeading = (constraint.secondItem as? UIView) == viewController.view && constraint.secondAttribute == .leading
            return isTitleLeading && isViewLeading
        }
        let trailingConstraint = constraints.first { constraint in
            let isTitleTrailing = constraint.firstAttribute == .trailing
            let isViewTrailing = (constraint.secondItem as? UIView) == viewController.view && constraint.secondAttribute == .trailing
            return isTitleTrailing && isViewTrailing
        }
        
        #expect(leadingConstraint != nil)
        #expect(trailingConstraint != nil)
        #expect(leadingConstraint?.isActive == true)
        #expect(trailingConstraint?.isActive == true)
    }
    
    @Test
    func test_configureTitleConstraints_whenLandscapeDuoFoldedOpenIsTrue_anchorsToSafeArea() async {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let mockActivityService = MockActivityService(
            context: coreData.viewContext
        )
        _ = ActivityItem.arrange(
            title: "Test 3",
            date: .arrange("10/04/2024"),
            context: coreData.viewContext
        )
        _ = ActivityItem.arrange(
            title: "Test 4",
            date: .arrange("11/04/2024"),
            context: coreData.viewContext
        )
        let request = ActivityItem.fetchRequest()
        let resultsController = NSFetchedResultsController<ActivityItem>(
            fetchRequest: request,
            managedObjectContext: coreData.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? resultsController.performFetch()
        mockActivityService._stubbedFetchResultsController = resultsController
        
        let viewController = TestableRecentActivityListViewController(
            viewModel: .init(
                activityService: mockActivityService,
                analyticsService: MockAnalyticsService(),
                selectedAction: { _ in }
            )
        )
        
        viewController.stubbedIsLandscapeDuoFoldedOpen = true
        _ = viewController.view
        
        let constraints = viewController.view.constraints
        let leadingSafeAreaConstraint = constraints.first { constraint in
            let isTitleLeading = constraint.firstAttribute == .leading
            let isSafeAreaLeading = constraint.secondItem is UILayoutGuide && constraint.secondAttribute == .leading
            return isTitleLeading && isSafeAreaLeading
        }
        let trailingSafeAreaConstraint = constraints.first { constraint in
            let isTitleTrailing = constraint.firstAttribute == .trailing
            let isSafeAreaTrailing = constraint.secondItem is UILayoutGuide && constraint.secondAttribute == .trailing
            return isTitleTrailing && isSafeAreaTrailing
        }
        
        #expect(leadingSafeAreaConstraint != nil)
        #expect(trailingSafeAreaConstraint != nil)
        #expect(leadingSafeAreaConstraint?.isActive == true)
    }
}

