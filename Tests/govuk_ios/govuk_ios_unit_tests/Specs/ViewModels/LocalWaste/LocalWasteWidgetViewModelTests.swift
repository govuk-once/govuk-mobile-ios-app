import Foundation
import Testing
import UIKit

@testable import govuk_ios

@MainActor
@Suite
struct LocalWasteWidgetViewModelTests {

    @Test
    func title_returnsCorrectValue() throws {
        let sut = LocalWasteWidgetViewModel(
            service: MockLocalWasteService(),
            openEditViewAction: { },
            openScheduleViewAction: { }
        )
        let expected = String.localWaste.localized(
            "localWasteTitle"
        )
        #expect(sut.title == expected)
    }

    @Test
    func editButton_returnsCorrectValue() throws {
        let sut = LocalWasteWidgetViewModel(
            service: MockLocalWasteService(),
            openEditViewAction: { },
            openScheduleViewAction: { }
        )
        let expected = String.common.localized(
            "editButtonTitle"
        )
        #expect(sut.editButton == expected)
    }

    @Test
    func scheduleButton_returnsCorrectValue() throws {
        let sut = LocalWasteWidgetViewModel(
            service: MockLocalWasteService(),
            openEditViewAction: { },
            openScheduleViewAction: { }
        )
        let expected = String.localWaste.localized(
            "localWasteWidgetViewScheduleButton"
        )
        #expect(sut.scheduleButton == expected)
    }

    @Test
    func editButtonAccessibilityLabel_returnsCorrectValue() throws {
        let sut = LocalWasteWidgetViewModel(
            service: MockLocalWasteService(),
            openEditViewAction: { },
            openScheduleViewAction: { }
        )
        let expected = String.localWaste.localized(
            "localWasteEditButtonAccessibilityLabel"
        )
        #expect(sut.editButtonAccessibilityLabel == expected)
    }

    @Test
    func loadingAccessibilityLabel_returnsCorrectValue() throws {
        let sut = LocalWasteWidgetViewModel(
            service: MockLocalWasteService(),
            openEditViewAction: { },
            openScheduleViewAction: { }
        )
        let expected = String.localWaste.localized(
            "localWasteWidgetViewLoadingAccessibilityLabel"
        )
        #expect(sut.loadingAccessibilityLabel == expected)
    }

    @Test
    func dueTimeLabel_returnsCorrectValue() throws {
        let sut = LocalWasteWidgetViewModel(
            service: MockLocalWasteService(),
            openEditViewAction: { },
            openScheduleViewAction: { }
        )
        let expected = String.localWaste.localized(
            "localWasteWidgetViewDueTimeLabel"
        )
        #expect(sut.dueTimeLabel == expected)
    }

    @Test
    func emptyLabel_returnsCorrectValue() throws {
        let sut = LocalWasteWidgetViewModel(
            service: MockLocalWasteService(),
            openEditViewAction: { },
            openScheduleViewAction: { }
        )
        let expected = String.localWaste.localized(
            "localWasteWidgetViewEmptyLabel"
        )
        #expect(sut.emptyLabel == expected)
    }

    @Test
    func errorLabel_returnsCorrectValue() throws {
        let sut = LocalWasteWidgetViewModel(
            service: MockLocalWasteService(),
            openEditViewAction: { },
            openScheduleViewAction: { }
        )
        let expected = String.localWaste.localized(
            "localWasteWidgetViewErrorLabel"
        )
        #expect(sut.errorLabel == expected)
    }

    @Test
    func tryAgainButton_returnsCorrectValue() throws {
        let sut = LocalWasteWidgetViewModel(
            service: MockLocalWasteService(),
            openEditViewAction: { },
            openScheduleViewAction: { }
        )
        let expected = String.localWaste.localized(
            "localWasteWidgetViewTryAgainButton"
        )
        #expect(sut.tryAgainButton == expected)
    }

    @Test
    func fetchAddress_serviceReturnsNil_showError() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = nil
        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        #expect(sut.viewState == .error)
        #expect(sut.address == "")
        #expect(sut.addressAccessibilityLabel == "")
        #expect(sut.dueDate == "")
        #expect(sut.items == [])
    }

    @Test
    func fetchSchedule_serviceThrows_showError() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._errorFetchSchedule = .apiUnavailable
        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        #expect(sut.address == "")
        #expect(sut.addressAccessibilityLabel == "")
        #expect(sut.dueDate == "")
        #expect(sut.isScheduleAvailable == false)
        #expect(sut.items == [])
    }

    @Test
    func fetchSchedule_serviceReturnsSchedule_addressSet() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = Constants.schedule
        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        #expect(sut.address == Constants.address.addressFull)
        #expect(sut.addressAccessibilityLabel == "Your address: \(Constants.address.addressFull)")
        #expect(sut.viewState == .ready)
    }

    @Test
    func fetchSchedule_serviceReturnsEmpty_propertiesSet() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = []
        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        #expect(sut.items == [])
        #expect(sut.dueDate == "")
        #expect(sut.address == Constants.address.addressFull)
        #expect(sut.addressAccessibilityLabel == "Your address: \(Constants.address.addressFull)")
        #expect(sut.isScheduleAvailable == false)
        #expect(sut.viewState == .ready)
    }

    @Test
    func fetchSchedule_serviceReturnsSchedule_itemsSet() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = Constants.schedule
        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )
        let expectedSchedule: [ItemViewModel] = [
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

        await sut.load()

        #expect(sut.items == expectedSchedule)
        #expect(sut.viewState == .ready)
    }

    @Test
    func fetchSchedule_serviceReturnsSchedule_today_dueDateSet() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = Constants.schedule
        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        #expect(sut.dueDate == "Due today")
        #expect(sut.viewState == .ready)
    }

    @Test
    func fetchSchedule_serviceReturnsSchedule_multipleDays_isScheduleAvailable() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = [
            .init(date: Constants.today(),
                  name: "General Waste",
                  color: .black,
                  content: "All waste"),
            .init(date: Constants.tomorrow(),
                  name: "Recycling",
                  color: .green,
                  content: "All recycling"),
        ]

        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        #expect(sut.isScheduleAvailable == true)
    }

    @Test
    func fetchSchedule_serviceReturnsSchedule_multipleDaysIgnorePast_isScheduleAvailable() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = [
            .init(date: Constants.yesterday(),
                  name: "General Waste",
                  color: .black,
                  content: "All waste"),
            .init(date: Constants.today(),
                  name: "Recycling",
                  color: .green,
                  content: "All recycling"),
        ]

        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        #expect(sut.isScheduleAvailable == false)
    }

    @Test
    func fetchSchedule_serviceReturnsSchedule_singleDay_isScheduleAvailable() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = [
            .init(date: Constants.today(),
                  name: "General Waste",
                  color: .black,
                  content: "All waste"),
            .init(date: Constants.today(),
                  name: "Recycling",
                  color: .green,
                  content: "All recycling"),
        ]

        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        #expect(sut.isScheduleAvailable == false)
    }

    @Test
    func fetchSchedule_serviceReturnsSchedule_tomorrow_dueDateSet() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = [
            .init(date: Constants.tomorrow(),
                  name: "General Waste",
                  color: .black,
                  content: "All waste"),
        ]

        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        #expect(sut.dueDate == "Due tomorrow")
        #expect(sut.viewState == .ready)
    }

    @Test
    func fetchSchedule_serviceReturnsSchedule_dayAfterTomorrow_dueDateSet() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = [
            .init(date: Constants.dayAfterTomorrow(),
                  name: "General Waste",
                  color: .black,
                  content: "All waste"),
        ]

        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        let formattedDate = formatter.string(from: Constants.dayAfterTomorrow())

        #expect(sut.dueDate == "Due \(formattedDate)")
        #expect(sut.viewState == .ready)
    }

    @Test
    func fetchSchedule_serviceReturnsSchedule_onlyPastDates_propertiesSet() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = [
            .init(date: Constants.yesterday(),
                  name: "General Waste",
                  color: .black,
                  content: "All waste"),
        ]

        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        #expect(sut.items == [])
        #expect(sut.dueDate == "")
        #expect(sut.address == Constants.address.addressFull)
        #expect(sut.addressAccessibilityLabel == "Your address: \(Constants.address.addressFull)")
        #expect(sut.viewState == .ready)
    }

    @Test
    func fetchSchedule_serviceReturnsSchedule_onlyFutureDates_propertiesSet() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = [
            .init(date: Constants.tomorrow(),
                  name: "General Waste",
                  color: .black,
                  content: "All waste"),
        ]

        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        let expectedSchedule: [ItemViewModel] = [
            .init(color: .black,
                  title: "General Waste",
                  description: "All waste")
        ]

        #expect(sut.items == expectedSchedule)
        #expect(sut.viewState == .ready)
    }

    @Test
    func fetchSchedule_serviceReturnsSchedule_mixOfDates_earliestOnly_propertiesSet() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = [
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

        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        let expectedSchedule: [ItemViewModel] = [
            .init(color: .black,
                  title: "General Waste",
                  description: "All waste")
        ]

        #expect(sut.items == expectedSchedule)
        #expect(sut.viewState == .ready)
    }

    @Test
    func onViewScheduleTapped_pushScheduleCache() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = Constants.schedule
        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )
        await sut.load()

        sut.onViewScheduleTapped()

        #expect(mockLocalWasteService._scheduleCache == Constants.schedule)
    }

    @Test
    func onViewScheduleTapped_callsScheduleViewAction() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = Constants.schedule
        var openScheduleViewActionCalled = false
        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: {
                openScheduleViewActionCalled = true
            }
        )
        await sut.load()

        sut.onViewScheduleTapped()

        #expect(openScheduleViewActionCalled == true)
    }

    @Test
    func resetViewState_resetsProperties() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddress = Constants.address
        mockLocalWasteService._dataFetchSchedule = Constants.schedule
        let sut = LocalWasteWidgetViewModel(
            service: mockLocalWasteService,
            openEditViewAction: { },
            openScheduleViewAction: { }
        )

        await sut.load()

        sut.resetViewState()

        #expect(sut.items == [])
        #expect(sut.address == "")
        #expect(sut.addressAccessibilityLabel == "")
        #expect(sut.dueDate == "")
        #expect(sut.viewState == .initial)
    }

    @Test
    func localWasteBinColor_accessibilityLabel_black_returnsCorrectTitle() throws {
        let sut = LocalWasteBinColor.black
        let expected = String.localWaste.localized(
            "localWasteColorAccessibilityBlack"
        )
        #expect(sut.accessibilityLabel == expected)
    }

    @Test
    func localWasteBinColor_accessibilityLabel_green_returnsCorrectTitle() throws {
        let sut = LocalWasteBinColor.green
        let expected = String.localWaste.localized(
            "localWasteColorAccessibilityGreen"
        )
        #expect(sut.accessibilityLabel == expected)
    }

    @Test
    func localWasteBinColor_accessibilityLabel_red_returnsCorrectTitle() throws {
        let sut = LocalWasteBinColor.red
        let expected = String.localWaste.localized(
            "localWasteColorAccessibilityRed"
        )
        #expect(sut.accessibilityLabel == expected)
    }

    @Test
    func localWasteBinColor_accessibilityLabel_blue_returnsCorrectTitle() throws {
        let sut = LocalWasteBinColor.blue
        let expected = String.localWaste.localized(
            "localWasteColorAccessibilityBlue"
        )
        #expect(sut.accessibilityLabel == expected)
    }

    @Test
    func localWasteBinColor_accessibilityLabel_brown_returnsCorrectTitle() throws {
        let sut = LocalWasteBinColor.brown
        let expected = String.localWaste.localized(
            "localWasteColorAccessibilityBrown"
        )
        #expect(sut.accessibilityLabel == expected)
    }

    @Test
    func localWasteBinColor_accessibilityLabel_yellow_returnsCorrectTitle() throws {
        let sut = LocalWasteBinColor.yellow
        let expected = String.localWaste.localized(
            "localWasteColorAccessibilityYellow"
        )
        #expect(sut.accessibilityLabel == expected)
    }

    @Test
    func localWasteBinColor_accessibilityLabel_silver_returnsCorrectTitle() throws {
        let sut = LocalWasteBinColor.silver
        let expected = String.localWaste.localized(
            "localWasteColorAccessibilitySilver"
        )
        #expect(sut.accessibilityLabel == expected)
    }

    @Test
    func localWasteBinColor_accessibilityLabel_purple_returnsCorrectTitle() throws {
        let sut = LocalWasteBinColor.purple
        let expected = String.localWaste.localized(
            "localWasteColorAccessibilityPurple"
        )
        #expect(sut.accessibilityLabel == expected)
    }

    @Test
    func itemViewModel_id_allSet() throws {
        let sut = ItemViewModel(
            color: .black,
            title: "Plastics",
            description: "Hard plastics only")
        #expect(sut.id == "black!Plastics!Hard plastics only")
    }

    @Test
    func itemViewModel_id_noColor() throws {
        let sut = ItemViewModel(
            color: nil,
            title: "Plastics",
            description: "Hard plastics only")
        #expect(sut.id == "!Plastics!Hard plastics only")
    }

    @Test
    func itemViewModel_id_noDescription() throws {
        let sut = ItemViewModel(
            color: .black,
            title: "Plastics",
            description: nil)
        #expect(sut.id == "black!Plastics!")
    }

    @Test
    func itemViewModel_accessibilityLabel_allSet() throws {
        let sut = ItemViewModel(
            color: .black,
            title: "Plastics",
            description: "Hard plastics only")
        #expect(sut.accessibilityLabel == "Plastics, Black, Hard plastics only")
    }

    @Test
    func itemViewModel_accessibilityLabel_noColor() throws {
        let sut = ItemViewModel(
            color: nil,
            title: "Plastics",
            description: "Hard plastics only")
        #expect(sut.accessibilityLabel == "Plastics, Hard plastics only")
    }

    @Test
    func itemViewModel_accessibilityLabel_noDescription() throws {
        let sut = ItemViewModel(
            color: .black,
            title: "Plastics",
            description: nil)
        #expect(sut.accessibilityLabel == "Plastics, Black")
    }

    @Test
    func itemViewModel_accessibilityLabel_onlyTitle() throws {
        let sut = ItemViewModel(
            color: nil,
            title: "Plastics",
            description: nil)
        #expect(sut.accessibilityLabel == "Plastics")
    }

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
