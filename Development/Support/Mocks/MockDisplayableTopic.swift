#if DEBUG
import Foundation

struct MockDisplayableTopic: DisplayableTopic {
    let ref: String
    let title: String
    let topicDescription: String?
}
#endif // DEBUG
