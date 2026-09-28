import Foundation

enum ChatFeedbackState: Equatable {
    case unrated
    case rated(isPositive: Bool)
    case surveyOpened(isPositive: Bool)
    case confirmed
}
