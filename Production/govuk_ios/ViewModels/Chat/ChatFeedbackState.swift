import Foundation

enum ChatFeedbackState: Equatable {
    case unrated
    case submitting
    case rated(isPositive: Bool)
    case surveyOpened(isPositive: Bool)
    case confirmed
}
