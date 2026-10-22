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

@Suite(.serialized)
@MainActor
struct RecentActivityListViewControllerTests {
    private let coreData: CoreDataRepository
    private let mockActivityService: MockActivityService
    
    init() async throws {
        let repository = await CoreDataRepository.arrangeAndLoad
        self.coreData = repository
        
        let service = MockActivityService(context: repository.viewContext)
        let request = ActivityItem.fetchRequest()
        let defaultController = NSFetchedResultsController<ActivityItem>(
            fetchRequest: request,
            managedObjectContext: repository.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? defaultController.performFetch()
        service._stubbedFetchResultsController = defaultController
        
        self.mockActivityService = service
    }
    
    @Test
    func test_isLandscapeDuoFoldedOpen_withNoWindow_returnsFalse() async {
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
    
    @Test
        func test_selectAllButtonPressed_isPressed() async throws {
            let viewController = RecentActivityListViewController(
                viewModel: .init(
                    activityService: mockActivityService,
                    analyticsService: MockAnalyticsService(),
                    selectedAction: { _ in }
                )
            )
            _ = viewController.view
            viewController.selectAllButtonPressed()
            #expect(true)
        }
}

