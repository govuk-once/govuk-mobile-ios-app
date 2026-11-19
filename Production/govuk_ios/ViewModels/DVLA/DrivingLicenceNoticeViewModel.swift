import Foundation

struct DrivingLicenceNoticeViewModel {
    struct Action {
        let buttonTitle: String
        let handler: () -> Void
    }
    let title: String
    let body: String
    let action: Action?
}
