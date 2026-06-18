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
            detailTappedAction: { _ in },
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
            detailTappedAction: { _ in },
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
            detailTappedAction: { _ in },
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        var vehicleSummaryViewModels: [VehicleSummaryViewModel]?
        if case .loaded(let vehicles) = sut.viewState {
            vehicleSummaryViewModels = vehicles
        }
        vehicleSummaryViewModels?.first?.detailTappedAction()

        let navigationEvent = mockAnalyticsService._trackedEvents.first
        #expect(navigationEvent?.params?["text"] as? String == "Details")
        #expect(navigationEvent?.params?["type"] as? String == "Button")
        #expect(navigationEvent?.params?["section"] as? String == "Driving")
        #expect(navigationEvent?.name == "Navigation")
    }

    @Test
    func viewDidAppear_fetchVehiclesFailure_createsErrorViewModel() async throws {
        mockDvlaService._stubbedFetchCustomerSummaryResult = .failure(.apiUnavailable)
        let sut = VehiclesViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            detailTappedAction: { _ in },
            openURLAction: { _ in }
        )
        await sut.viewDidAppear()
        var errorViewModel: AppErrorViewModel?
        if case .error(let error) = sut.viewState {
            errorViewModel = error
        }
        #expect(errorViewModel?.title == String.common.localized("genericErrorTitle"))
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
                detailTappedAction: { _ in },
                openURLAction: { _ in confirmation() }
            )

            await sut.viewDidAppear()
            #expect(mockDvlaService._fetchCustomerSummaryCallCount == 1)

            sut.addNewVehiclesAction()

            await sut.viewDidAppear()
            #expect(mockDvlaService._fetchCustomerSummaryCallCount == 2)
        }
    }

    @Test
    func addNewVehiclesAction_tracksEvent() async {
        let sut = VehiclesViewModel(
            analyticsService: mockAnalyticsService,
            dvlaService: mockDvlaService,
            configService: mockConfigService,
            detailTappedAction: { _ in },
            openURLAction: { _ in }
        )

        sut.addNewVehiclesAction()

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "Add your vehicle")
    }
}
