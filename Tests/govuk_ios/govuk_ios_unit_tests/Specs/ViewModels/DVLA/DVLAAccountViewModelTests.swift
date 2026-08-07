import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

struct DVLAAccountViewModelTests {

    var mockDvlaService: MockDVLAService!

    init() {
        mockDvlaService = MockDVLAService()
    }

    @Test
    func fetchContent_vehicle_success_createsSectionCorrectly() async throws {
        mockDvlaService._stubbedFetchVehicleResult = .success(.arrange)
        let sut = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .vehicle
        )
        await sut.fetchContent()
        try #require(sut.sections.count == 1)
        try #require(sut.sections.first?.rows.count == 7)
        #expect(sut.sections[0].rows[0].title == "Make")
        #expect(sut.sections[0].rows[0].body == "FORD")
    }

    @Test
    func fetchContent_shareCodesList_success_createsSectionCorrectly() async throws {
        mockDvlaService._stubbedFetchShareCodesResult = .success(.arrange)
        let sut = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .shareCodeList
        )
        await sut.fetchContent()
        #expect(sut.sections.count == 1)
        let section = try #require(sut.sections.first)
        let expectedShareCodeRowTitle = """
            Token: ABC-123
            Created: 1 January 1970
            Expiry: 1 January 1970
            State: valid
            """
        #expect(section.rows.count == 2)
        #expect(section.rows[0].title == expectedShareCodeRowTitle)
    }

    @Test
    func fetchContent_createShareCode_success_createsSectionCorrectly() async throws {
        mockDvlaService._stubbedCreateShareCodeResult = .success(.arrange)
        let sut = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .createShareCode
        )
        await sut.fetchContent()
        #expect(sut.sections.count == 1)
        let section = try #require(sut.sections.first)
        let expectedShareCodeRowTitle = """
            Token: ABC-123
            Created: 1 January 1970
            Expiry: 1 January 1970
            State: valid
            """
        #expect(section.rows[0].title == expectedShareCodeRowTitle)
    }

    @Test
    func shareCodeRow_action_callsCancelShareCode() async throws {
        mockDvlaService._stubbedFetchShareCodesResult = .success(.arrange)
        mockDvlaService._stubbedCancelShareCodeResult = .success(.arrange)
        let sut = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .shareCodeList
        )
        await sut.fetchContent()
        let section = sut.sections.first
        let row = try #require(section?.rows.first as? DetailRow)
        #expect(row.body == "Cancel")
        await withCheckedContinuation { continuation in
            mockDvlaService._cancelShareCodeCalledContinuation = continuation
            row.action()
        }
        #expect(mockDvlaService._cancelShareCodeCallCount == 1)
    }

    @Test
    func cancelShareCode_success_displaysAlert() async {
        mockDvlaService._stubbedCancelShareCodeResult = .success(.arrange)
        mockDvlaService._stubbedFetchShareCodesResult = .success(.arrange)
        let sut = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .shareCodeList
        )
        await sut.cancelShareCode(.arrange)
        #expect(sut.showAlert == true)
        #expect(sut.alertMessage == "Check code cancelled successfully")

        await sut.handleShareCodeAlertDismissed()
        #expect(sut.showAlert == false)
        #expect(sut.alertMessage == "")
    }
}
