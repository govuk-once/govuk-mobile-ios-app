import Foundation
import SwiftUI

@testable import govuk_ios

class MockTopicWidgetProvider: TopicWidgetProvider {
    var _stubbedWidget: AnyView?
    var _makeWidgetCalled = false
    func makeWidget(for topic: DisplayableTopic) -> AnyView? {
        _makeWidgetCalled = true
        return _stubbedWidget
    }
}
