import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@Suite
struct VehiclesViewModelTests {

    var mockAnalyticsService: MockAnalyticsService!
    var mockDvlaService: MockDVLAService!
    var mockConfigService: MockAppConfigService!

    init() {
        mockAnalyticsService = MockAnalyticsService()
        mockDvlaService = MockDVLAService()
        mockConfigService = MockAppConfigService()
    }

    @Test
    func viewDidAppear_fetchesVehicles() async {
        mockDvlaService._stubbedFetchCustomerSummaryResult = .success(.arrange)
        let sut = VehiclesViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            detailAction: { _ in },
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        #expect(mockDvlaService._fetchCustomerSummaryCallCount == 1)
    }

    @Test
    func viewDidAppear_fetchVehiclesSuccess_createsVehicleSummaryViewModels() async throws {
        let mockVehicles: [CustomerSummary.Vehicle] = [
            .arrange(registrationNumber: "ABC 123"),
            .arrange(registrationNumber: "DEF 456")
        ]
        mockDvlaService._stubbedFetchCustomerSummaryResult = .success(
            .arrange(vehicles: mockVehicles)
        )
        let sut = VehiclesViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            detailAction: { _ in },
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        var vehicleSummaryViewModels: [VehicleSummaryViewModel]?
        if case .loaded(let vehicles) = sut.viewState {
            vehicleSummaryViewModels = vehicles
        }
        #expect(vehicleSummaryViewModels?.count == 2)
        let vehicleSummaryViewModel = try #require(vehicleSummaryViewModels?.first)
        #expect(vehicleSummaryViewModel.registrationNumber == "ABC 123")
    }

    @Test
    func vehicleSummaryViewModel_detailsButtonAction_tracksNavigationEvent() async {
        let mockVehicles: [CustomerSummary.Vehicle] = [
            .arrange(registrationNumber: "ABC 123")
        ]
        mockDvlaService._stubbedFetchCustomerSummaryResult = .success(
            .arrange(vehicles: mockVehicles)
        )
        let sut = VehiclesViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            detailAction: { _ in },
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        var vehicleSummaryViewModels: [VehicleSummaryViewModel]?
        if case .loaded(let vehicles) = sut.viewState {
            vehicleSummaryViewModels = vehicles
        }
        vehicleSummaryViewModels?.first?.detailAction()

        let navigationEvent = mockAnalyticsService._trackedEvents.first
        #expect(navigationEvent?.params?["text"] as? String == "Details")
        #expect(navigationEvent?.params?["type"] as? String == "Button")
        #expect(navigationEvent?.params?["section"] as? String == "Driving")
        #expect(navigationEvent?.name == "Navigation")
    }

    @Test
    func viewDidAppear_fetchVehiclesFailure_createsErrorViewModel() async throws {
        let mockAccountURLString = "https://dvla.gov.uk/account"
        mockDvlaService._stubbedFetchCustomerSummaryResult = .failure(.apiUnavailable)
        mockConfigService._dvlaUrls = .arrange(account: mockAccountURLString)
        let sut = VehiclesViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            detailAction: { _ in },
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        var errorViewModel: InlineActionErrorViewModel?
        if case .error(let error) = sut.viewState {
            errorViewModel = error
        }
        #expect(errorViewModel?.title == String(localized: .DVLA.vehicleSummaryErrorTitle))
        let expectedButtonTitle = String(localized: .DVLA.vehicleSummaryErrorButtonTitle)
        let expectedMarkdownBody = String(localized: .DVLA.vehicleSummaryErrorBody(
            buttonTitle: expectedButtonTitle,
            url: mockAccountURLString)
        )
        #expect(errorViewModel?.markdownBody == expectedMarkdownBody)
        errorViewModel?.openURLAction(URL(string: mockAccountURLString)!)
        let trackedEvent = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(trackedEvent.name == "Navigation")
        #expect(trackedEvent.params?["text"] as? String == expectedButtonTitle)
        #expect(trackedEvent.params?["url"] as? String == mockAccountURLString)
        #expect(trackedEvent.params?["section"] as? String == "Driving")
        #expect(trackedEvent.params?["type"] as? String == "Button")
    }

    @Test
    @MainActor
    func addNewVehiclesAction_opensURLAndResetsVehiclesLoaded() async {
        mockDvlaService._stubbedFetchCustomerSummaryResult = .success(.arrange)
        await confirmation() { confirmation in
            let sut = VehiclesViewModel(
                analyticsService: mockAnalyticsService,
                dvlaService: mockDvlaService,
                configService: mockConfigService,
                detailAction: { _ in },
                openURLAction: { _ in confirmation() }
            )

            await sut.viewDidAppear()
            #expect(mockDvlaService._fetchCustomerSummaryCallCount == 1)

            sut.addNewVehiclesAction(largeCard: true)

            await sut.viewDidAppear()
            #expect(mockDvlaService._fetchCustomerSummaryCallCount == 2)
        }
    }

    @Test
    func addNewVehiclesAction_largeCard_tracksEvent() async {
        let sut = VehiclesViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            detailAction: { _ in },
            openURLAction: { _ in }
        )

        sut.addNewVehiclesAction(largeCard: true)

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "Add your vehicle")
        #expect(mockAnalyticsService._trackedEvents.first?.params?["type"] as? String == "Account card")
    }

    @Test
    func addNewVehiclesAction_smallCard_tracksEvent() async {
        let sut = VehiclesViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            detailAction: { _ in },
            openURLAction: { _ in }
        )

        sut.addNewVehiclesAction(largeCard: false)

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "Add vehicle")
        #expect(mockAnalyticsService._trackedEvents.first?.params?["type"] as? String == "Button")
    }
}
