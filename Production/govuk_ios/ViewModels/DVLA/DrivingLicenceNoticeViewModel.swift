import Foundation

struct DrivingLicenceNoticeViewModel {
    struct Action {
        let buttonTitle: String
        let handler: () -> Void
    }

    enum TitleStyle {
        case normal
        case inverted
    }

    let title: String
    let titleStyle: TitleStyle
    let body: String
    let action: Action?

    init(
        title: String,
        titleStyle: TitleStyle = .normal,
        body: String,
        action: Action? = nil
    ) {
        self.title = title
        self.titleStyle = titleStyle
        self.body = body
        self.action = action
    }
}
