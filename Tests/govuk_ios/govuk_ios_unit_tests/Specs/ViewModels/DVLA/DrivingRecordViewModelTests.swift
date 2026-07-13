import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@Suite
struct DrivingRecordViewModelTests {

    @Test
    func init_returnsExpectedResult() throws {
        let sut = DrivingRecordViewModel(
            dvlaURLs: .arrange,
            openURLAction: { _, _ in }
        )
        let drivingRecordRow = try #require(sut.listContent.first?.rows.first)
        #expect(drivingRecordRow.title == String(localized: .DVLA.drivingRecordButtonTitle))
    }

    @Test
    func drivingRecordRowAction_callsOpenURLAction() throws {
        var receivedButtonTitle: String?
        var receivedOpenURL: URL?
        let mockDrivingRecordUrl = "https://dvla.gov.uk/driving-record"
        let sut = DrivingRecordViewModel(
            dvlaURLs: .arrange(drivingRecord: mockDrivingRecordUrl),
            openURLAction: { url, buttonTitle in
                receivedOpenURL = url
                receivedButtonTitle = buttonTitle
            }
        )
        let drivingRecordRow = try #require(sut.listContent.first?.rows.first as? LinkRow)
        drivingRecordRow.action()
        #expect(receivedButtonTitle == String(localized: .DVLA.drivingRecordButtonTitle))
        #expect(receivedOpenURL?.absoluteString == mockDrivingRecordUrl)
    }
}
