import Foundation
import Testing
import Combine

@testable import GovKit
@testable import govuk_ios

@Suite
struct StoredLocalAuthorityWidgetViewModelTests {

    @Test
    func openURL_opensCorrectURL() async {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let localAuthorityItem = LocalAuthorityItem(
            context: coreData.backgroundContext
        )
        localAuthorityItem.name = "Test Local Authority"
        localAuthorityItem.slug = "slug"
        localAuthorityItem.homepageUrl = "https://www.gov.uk/some-url"
        localAuthorityItem.tier = "unitary"
        var openedURL: URL?
        let expectedItem = StoredLocalAuthorityCardModel.arrange
        await withCheckedContinuation { continuation in
            let sut = StoredLocalAuthorityWidgetViewModel(
                analyticsService: MockAnalyticsService(),
                localAuthorityService: MockLocalAuthorityService(),
                localAuthorities: [localAuthorityItem],
                openURLAction: { localUrl in
                    openedURL = localUrl
                    continuation.resume()
                },
                openEditViewAction: {},
                deleteCompletion: { }
            )
            sut.open(item: expectedItem)
        }
        #expect(openedURL?.absoluteString == expectedItem.homepageUrl)
    }


    @Test
    func openURL_tracksEventCorrectly() async {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let mockAnalyticsService: MockAnalyticsService = MockAnalyticsService()
        let localAuthorityItem = LocalAuthorityItem(
            context: coreData.backgroundContext
        )
        localAuthorityItem.name = "Test Local Authority"
        localAuthorityItem.slug = "slug"
        localAuthorityItem.homepageUrl = "https://www.gov.uk/some-url"
        localAuthorityItem.tier = "unitary"

        let sut = StoredLocalAuthorityWidgetViewModel(
            analyticsService: mockAnalyticsService,
            localAuthorityService: MockLocalAuthorityService(),
            localAuthorities: [localAuthorityItem],
            openURLAction: { _ in },
            openEditViewAction: {},
            deleteCompletion: { }
        )
        let item = StoredLocalAuthorityCardModel.arrange
        sut.open(item: item)
        let receivedTrackingTitle = mockAnalyticsService._trackedEvents.first?.params?["text"] as? String
        #expect(receivedTrackingTitle == item.name)
    }

    @Test
    func convertModel_unitaryAuthority_returnsExpectedResult() async {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let mockAuthorityItem = LocalAuthorityItem(
            context: coreData.backgroundContext
        )
        mockAuthorityItem.name = "London Borough of Tower Hamlets"
        mockAuthorityItem.slug = "tower-hamlets"
        mockAuthorityItem.homepageUrl = "https://www.towerhamlets.gov.uk"
        mockAuthorityItem.tier = "unitary"

        let sut = StoredLocalAuthorityWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            localAuthorityService: MockLocalAuthorityService(),
            localAuthorities: [mockAuthorityItem],
            openURLAction: { _ in },
            openEditViewAction: {},
            deleteCompletion: { }
        )

        let result = sut.cardModels()
        #expect(result.count == 1)
        #expect(result.first?.homepageUrl == "https://www.towerhamlets.gov.uk")
        #expect(result.first?.description == nil)
    }

    @Test
    func convertModel_twoTier_returnsExpectedResult() async {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let parentAuthority = LocalAuthorityItem(
            context: coreData.backgroundContext
        )
        parentAuthority.name = "Derbyshire County Council"
        parentAuthority.slug =  "derbyshire"
        parentAuthority.homepageUrl = "https://www.derbyshire.gov.uk/"
        parentAuthority.tier = "county"

        let childAuthority = LocalAuthorityItem(
            context: coreData.backgroundContext
        )
        childAuthority.name = "Derbyshire Dales District Council"
        childAuthority.slug = "derbyshire-dales"
        childAuthority.homepageUrl = "https://www.derbyshiredales.gov.uk/"
        childAuthority.tier = "district"
        childAuthority.parent = parentAuthority

        var authorityItems: [LocalAuthorityItem] = []
        authorityItems.append(parentAuthority)
        authorityItems.append(childAuthority)

        let sut = StoredLocalAuthorityWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            localAuthorityService: MockLocalAuthorityService(),
            localAuthorities: authorityItems,
            openURLAction: { _ in },
            openEditViewAction: {},
            deleteCompletion: { }
        )

        let result = sut.cardModels()
        #expect(result.count == 2)
        #expect(result.first?.homepageUrl == "https://www.derbyshire.gov.uk/")
        #expect(result.first?.description == "County councils are usually responsible for services like education, social care and transport")
    }

    @Test
    func changeAction_opensEditView() async {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let localAuthorityItem = LocalAuthorityItem(
            context: coreData.backgroundContext
        )
        await confirmation { confirmation in
            let sut = StoredLocalAuthorityWidgetViewModel(
                analyticsService: MockAnalyticsService(),
                localAuthorityService: MockLocalAuthorityService(),
                localAuthorities: [localAuthorityItem],
                openURLAction: { _ in },
                openEditViewAction: { confirmation() },
                deleteCompletion: { }
            )
            sut.changeAction()
        }
    }

    @Test
    func changeAction_tracksEvent() async {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let localAuthorityItem = LocalAuthorityItem(
            context: coreData.backgroundContext
        )
        let mockAnalyticsService = MockAnalyticsService()
        let sut = StoredLocalAuthorityWidgetViewModel(
            analyticsService: mockAnalyticsService,
            localAuthorityService: MockLocalAuthorityService(),
            localAuthorities: [localAuthorityItem],
            openURLAction: { _ in },
            openEditViewAction: { },
            deleteCompletion: { }
        )
        sut.changeAction()

        let receivedTrackingTitle = mockAnalyticsService._trackedEvents.first?.params?["text"] as? String
        #expect(receivedTrackingTitle == "Change")
    }

    @Test @MainActor
    func deleteAction_callsCompletion() async {
        let service = MockLocalAuthorityService()
        let completionSubject = PassthroughSubject<Void, Never>()
        var cancellable: AnyCancellable?

        let sut = StoredLocalAuthorityWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            localAuthorityService: service,
            localAuthorities: [],
            openURLAction: { _ in },
            openEditViewAction: {},
            deleteCompletion: {
                completionSubject.send(())
            }
        )

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            cancellable = completionSubject
                .sink { _ in continuation.resume() }

            sut.deleteAction()
        }

        #expect(service._deleteLocalAuthoritiesCalled)
        withExtendedLifetime(cancellable) {}
    }

    @Test
    func deleteAction_tracksEvent() async {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let localAuthorityItem = LocalAuthorityItem(
            context: coreData.backgroundContext
        )
        let mockAnalyticsService = MockAnalyticsService()
        let sut = StoredLocalAuthorityWidgetViewModel(
            analyticsService: mockAnalyticsService,
            localAuthorityService: MockLocalAuthorityService(),
            localAuthorities: [localAuthorityItem],
            openURLAction: { _ in },
            openEditViewAction: { },
            deleteCompletion: { }
        )
        sut.deleteAction()

        let receivedTrackingTitle = mockAnalyticsService._trackedEvents.first?.params?["text"] as? String
        #expect(receivedTrackingTitle == "Remove")
    }
}
