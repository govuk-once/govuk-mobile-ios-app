import Foundation
import SwiftUI

@testable import govuk_ios

class MockTopicWidgetProvider: TopicWidgetProvider {
    var _stubbedWidget: AnyView?
    var _widgetCalled = false
    func widget(for topic: DisplayableTopic) -> AnyView? {
        _widgetCalled = true
        return _stubbedWidget
    }
}
