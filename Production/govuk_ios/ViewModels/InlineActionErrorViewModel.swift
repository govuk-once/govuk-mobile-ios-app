import Foundation
import SwiftUI

struct InlineActionErrorViewModel {
    var title: String
    var markdownBody: String
    var openURLAction: ((URL) -> Void)
}
