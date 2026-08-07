import Foundation
import GovKit

struct DrivingRecordViewModel {
    let listContent: [GroupedListSection]

    init(dvlaURLs: DvlaURLs?, openURLAction: @escaping (URL, String) -> Void) {
        let buttonTitle = String(localized: .DVLA.drivingRecordButtonTitle)
        let url = dvlaURLs?.drivingRecord ?? Constants.API.defaultDvlaDrivingRecordUrl
        let drivingRecordRow = LinkRow(
            id: UUID().uuidString,
            title: buttonTitle,
            body: nil,
            showLinkImage: false,
            action: {
                openURLAction(url, buttonTitle)
            }
        )
        listContent = [
            GroupedListSection(
                heading: nil,
                rows: [drivingRecordRow],
                footer: nil
            )
        ]
    }
}
