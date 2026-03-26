import Foundation
import Testing
import UIKit

@testable import govuk_ios

@MainActor
@Suite
struct LocalWasteScheduleViewModelTests {

    @Test
    func viewTitle_returnsCorrectValue() throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._scheduleCache = Constants.schedule
        let sut = LocalWasteScheduleViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: { }
        )
        let expected = String.localWaste.localized(
            "localWasteScheduleViewTitle"
        )
        #expect(sut.viewTitle == expected)
    }

    @Test
    func viewSubtitle_returnsCorrectValue() throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._scheduleCache = Constants.schedule
        let sut = LocalWasteScheduleViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: { }
        )
        let expected = String.localWaste.localized(
            "localWasteScheduleViewSubtitle"
        )
        #expect(sut.viewSubtitle == expected)
    }

    @Test
    func cancelButton_returnsCorrectValue() throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._scheduleCache = Constants.schedule
        let sut = LocalWasteScheduleViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: { }
        )
        let expected = String.common.localized(
            "cancel"
        )
        #expect(sut.cancelButton == expected)
    }

    @Test
    func fetchAddress_serviceReturnsNil_addressEmpty() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = nil
        mockLocalWasteService._scheduleCache = Constants.schedule
        let sut = LocalWasteScheduleViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: { }
        )

        #expect(sut.address == "")
    }

    @Test
    func fetchAddress_serviceReturnsAddress_addressSet() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._scheduleCache = Constants.schedule
        let sut = LocalWasteScheduleViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: { }
        )

        #expect(sut.address == Constants.address.addressFull)
    }

    @Test
    func scheduleCache_serviceReturnsNil_itemsEmpty() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._scheduleCache = nil
        let sut = LocalWasteScheduleViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: { }
        )

        #expect(sut.items == [])
    }

    @Test
    func scheduleCache_serviceReturnsSchedule_itemsSet() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._scheduleCache = Constants.schedule
        let sut = LocalWasteScheduleViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: { }
        )

        let expectedSchedule: [GroupViewModel] = [
            .init(dateDisplay: "Today",
                  items: [
                    .init(color: .black,
                          title: "General Waste",
                          description: "All waste"),
                    .init(color: .blue,
                          title: "Paper",
                          description: "Paper, cardboard"),
                    .init(color: nil,
                          title: "Plastics",
                          description: "Hard plastics only")
                    ]
                  )
        ]

        #expect(sut.items == expectedSchedule)
    }

    @Test
    func scheduleCache_serviceReturnsSchedule_onlyPastDates_itemsEmpty() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._scheduleCache = [
            .init(date: Constants.yesterday(),
                  name: "General Waste",
                  color: .black,
                  content: "All waste"),
        ]
        let sut = LocalWasteScheduleViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: { }
        )

        #expect(sut.items == [])
    }

    @Test
    func fetchSchedule_serviceReturnsSchedule_mixOfDates_itemsSetSorted() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._scheduleCache = [
            .init(date: Constants.tomorrow(),
                  name: "Paper",
                  color: .blue,
                  content: "Paper, cardboard"),
            .init(date: Constants.today(),
                  name: "General Waste",
                  color: .black,
                  content: "All waste"),
            .init(date: Constants.dayAfterTomorrow(),
                  name: "Plastics",
                  color: nil,
                  content: "Hard plastics only")
        ]

        let sut = LocalWasteScheduleViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: { }
        )

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        let dayAfterTomorrowDate = formatter.string(from: Constants.dayAfterTomorrow())

        let expectedSchedule: [GroupViewModel] = [
            .init(dateDisplay: "Today",
                  items: [
                    .init(color: .black,
                          title: "General Waste",
                          description: "All waste")
                    ]
              ),
            .init(dateDisplay: "Tomorrow",
                  items: [
                    .init(color: .blue,
                          title: "Paper",
                          description: "Paper, cardboard")
                    ]
              ),
            .init(dateDisplay: dayAfterTomorrowDate,
                  items: [
                    .init(color: nil,
                          title: "Plastics",
                          description: "Hard plastics only")
                    ]
              ),
        ]

        #expect(sut.items == expectedSchedule)
    }

    @Test
    func trackScreen_sendsEvent() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = LocalWasteScheduleViewModel(
            service: MockLocalWasteService(),
            analyticsService: mockAnalyticsService,
            dismissAction: {}
        )
        let view = LocalWasteScheduleView(viewModel: sut)
        sut.trackScreen(screen: view)
        let screens = mockAnalyticsService._trackScreenReceivedScreens
        #expect(screens.count == 1)
        #expect(screens.first?.trackingName == view.trackingName)
        #expect(screens.first?.trackingTitle == view.trackingTitle)
    }

    fileprivate typealias GroupViewModel = LocalWasteScheduleGroupViewModel
    fileprivate typealias ItemViewModel = LocalWasteScheduleItemViewModel

    fileprivate enum Constants {
        static func yesterday() -> Date {
            Calendar.current.startOfDay(
                for: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            )
        }
        static func today() -> Date {
            Calendar.current.startOfDay(for: Date())
        }
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
